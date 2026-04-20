<?php

namespace App\Http\Controllers;

use App\Models\Kommentek;
use App\Models\Posztok;
use App\Models\FelhasznaloAdatok;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class KommentController extends Controller
{
    public function index($id)
    {
        try {
            $post = Posztok::find($id);

            if (!$post) {
                return response()->json(['error' => 'Post not found'], 404);
            }

            $comments = Kommentek::with([
                'kommentIro:id,felhasz_nev,profilKep_id',
                'kommentIro.profilKep:id,url_Link',
                'gyermekKommentek.kommentIro:id,felhasz_nev,profilKep_id',
                'gyermekKommentek.kommentIro.profilKep:id,url_Link',
                'gyermekKommentek.gyermekKommentek.kommentIro:id,felhasz_nev,profilKep_id',
                'gyermekKommentek.gyermekKommentek.kommentIro.profilKep:id,url_Link',
            ])
                ->where('poszt_id', $id)
                ->whereNull('elozetes_komment_id')
                ->orderBy('letrehozas_datuma', 'desc')
                ->get();

            $transform = function ($comment) use (&$transform) {
                $user = $comment->kommentIro;
                
                if ($comment->komment === '') {
                    // Placeholder komment — a felhasználó neve megjelenik ha még létezik
                    $felhasznalo = $user ? [
                        'id' => $user->id,
                        'felhasz_nev' => $user->felhasz_nev,
                        'profil_kep_url' => $user->profilKep?->url_Link,
                    ] : [
                        'id' => null,
                        'felhasz_nev' => $comment->kommentelo ? 'Törölt felhasználó' : 'Ismeretlen',
                        'profil_kep_url' => null,
                    ];
                } else {
                    // Normál komment
                    $felhasznalo = $user ? [
                        'id' => $user->id,
                        'felhasz_nev' => $user->felhasz_nev,
                        'profil_kep_url' => $user->profilKep?->url_Link,
                    ] : [
                        'id' => null,
                        'felhasz_nev' => 'Törölt felhasználó',
                        'profil_kep_url' => null,
                    ];
                }
                
                return [
                    'id' => $comment->id,
                    'komment' => $comment->komment,
                    'letrehozas_datuma' => $comment->letrehozas_datuma,
                    'poszt_id' => $comment->poszt_id,
                    'elozetes_komment_id' => $comment->elozetes_komment_id,
                    'felhasznalo' => $felhasznalo,
                    'gyermekKommentek' => $comment->gyermekKommentek->map($transform)->values()->toArray(),
                ];
            };

            $result = $comments->map($transform)->values()->toArray();

            return response()->json($result);

        } catch (\Exception $e) {
            Log::error('Error in KommentController@index: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function store(Request $request, $postId)
    {
        try {
            if (!Auth::check()) {
                return response()->json(['error' => 'Unauthorized'], 401);
            }

            $request->validate([
                'komment' => 'required|string|min:3|max:1000',
                'elozo_komment_id' => 'nullable|exists:kommentek,id',
            ]);

            $comment = Kommentek::create([
                'komment' => $request->komment,
                'poszt_id' => $postId,
                'kommentelo' => Auth::id(),
                'elozetes_komment_id' => $request->elozo_komment_id,
                'letrehozas_datuma' => now(),
            ]);

            $comment->load('kommentIro:id,felhasz_nev,profilKep_id', 'kommentIro.profilKep:id,url_Link');

            $user = $comment->kommentIro;

            $commentData = [
                'id' => $comment->id,
                'komment' => $comment->komment,
                'letrehozas_datuma' => $comment->letrehozas_datuma,
                'poszt_id' => $comment->poszt_id,
                'elozetes_komment_id' => $comment->elozetes_komment_id,
                'felhasznalo' => [
                    'id' => $user->id,
                    'felhasz_nev' => $user->felhasz_nev,
                    'profil_kep_url' => $user->profilKep?->url_Link,
                ],
                'gyermekKommentek' => [],
            ];

            return response()->json([
                'message' => 'Comment added!',
                'comment' => $commentData
            ], 201);

        } catch (\Exception $e) {
            Log::error('Error in KommentController@store: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function destroy(Request $request, $id)
    {
        $komment = Kommentek::findOrFail($id);

        $user = $request->user();
        $adatok = FelhasznaloAdatok::find($user->id);
        $szerepkor = $adatok?->szerepkor;
        
        if ((int)$komment->kommentelo !== (int)$user->id && !in_array($szerepkor, ['admin', 'moderator'])) {
            return response()->json(['message' => 'Nincs jogosultságod.'], 403);
        }

        $vanGyerek = Kommentek::where('elozetes_komment_id', $id)->exists();

        if ($vanGyerek) {
            $komment->komment = '';  // üres string = placeholder
            $komment->save();
            return response()->json(['message' => 'Komment törölve (placeholder).', 'deleted' => false]);
        }

        $szuloId = $komment->elozetes_komment_id;
        $komment->delete();

        if ($szuloId) {
            $this->cleanupPlaceholder($szuloId);
        }

        return response()->json(['message' => 'Komment törölve.', 'deleted' => true]);
    }

    private function cleanupPlaceholder($id)
    {
        $komment = Kommentek::find($id);
        if (!$komment) return;

        if ($komment->komment !== '') return;  // csak üres string = placeholder

        $vanGyerek = Kommentek::where('elozetes_komment_id', $id)->exists();
        if ($vanGyerek) return;

        $szuloId = $komment->elozetes_komment_id;
        $komment->delete();

        if ($szuloId) {
            $this->cleanupPlaceholder($szuloId);
        }
    }

    // Teljes lánc törlése (csak admin/moderátor)
    public function destroyChain(Request $request, $id)
    {
        $user = $request->user();
        $adatok = FelhasznaloAdatok::find($user->id);
        $szerepkor = $adatok?->szerepkor;

        if (!in_array($szerepkor, ['admin', 'moderator'])) {
            return response()->json(['message' => 'Nincs jogosultságod.'], 403);
        }

        $this->deleteChainRecursive($id);

        return response()->json(['message' => 'Kommentlánc törölve.']);
    }

    private function deleteChainRecursive($id)
    {
        $gyerekek = Kommentek::where('elozetes_komment_id', $id)->pluck('id');
        foreach ($gyerekek as $gyerekId) {
            $this->deleteChainRecursive($gyerekId);
        }
        Kommentek::where('id', $id)->delete();
    }
}