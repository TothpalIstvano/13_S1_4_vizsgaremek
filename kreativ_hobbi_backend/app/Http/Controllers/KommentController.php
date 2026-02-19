<?php

namespace App\Http\Controllers;

use App\Models\Kommentek;
use App\Models\Posztok;
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
                'gyermekKommentek.kommentIro.profilKep:id,url_Link'
            ])
                ->where('poszt_id', $id)
                ->whereNull('elozetes_komment_id')
                ->orderBy('letrehozas_datuma', 'desc')
                ->get();

            $transform = function ($comment) use (&$transform) {
                $user = $comment->kommentIro;
                return [
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

    public function destroy($id)
    {
        try {
            $comment = Kommentek::findOrFail($id);

            if ($comment->kommentelo !== Auth::id()) {
                return response()->json(['error' => 'You can only delete your own comments'], 403);
            }

            $comment->delete();
            return response()->json(['message' => 'Comment deleted!']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}