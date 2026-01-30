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

            $comments = Kommentek::with(['kommentIro:id,felhasz_nev', 'gyermekKommentek.kommentIro:id,felhasz_nev'])
                ->where('poszt_id', $id)
                ->whereNull('elozetes_komment_id')
                ->orderBy('letrehozas_datuma', 'desc')
                ->get()
                ->map(function ($comment) {
                    $commentArray = $comment->toArray();
                    if (isset($commentArray['komment_iro'])) {
                        $commentArray['felhasznalo'] = $commentArray['komment_iro'];
                        unset($commentArray['komment_iro']);
                    }

                    if (isset($commentArray['gyermek_kommentek'])) {
                        foreach ($commentArray['gyermek_kommentek'] as &$childComment) {
                            if (isset($childComment['komment_iro'])) {
                                $childComment['felhasznalo'] = $childComment['komment_iro'];
                                unset($childComment['komment_iro']);
                            }
                        }
                    }

                    return $commentArray;
                });

            return response()->json($comments);

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

            $comment->load('kommentIro:id,felhasz_nev');

            $commentData = $comment->toArray();
            if (isset($commentData['komment_iro'])) {
                $commentData['felhasznalo'] = $commentData['komment_iro'];
                unset($commentData['komment_iro']);
            }

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