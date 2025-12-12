<?php

namespace App\Http\Controllers;

use App\Models\Kommentek;
use App\Models\Posztok;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class KommentController extends Controller
{
    public function index($id)
    {
        try {
            // Simple test first - return hardcoded data
            return response()->json([
                ['id' => 1, 'komment' => 'Test comment 1', 'felhasznalo' => ['felhasz_nev' => 'Test User']],
                ['id' => 2, 'komment' => 'Test comment 2', 'felhasznalo' => ['felhasz_nev' => 'Another User']]
            ]);

            // If that works, uncomment below:
            /*
            $post = Posztok::find($id);

            if (!$post) {
                return response()->json(['error' => 'Post not found'], 404);
            }

            $comments = Kommentek::with('felhasznalo:id,felhasz_nev')
                ->where('poszt_id', $id)
                ->whereNull('elozetes_komment_id')
                ->orderBy('letrehozas_datuma', 'desc')
                ->get()
                ->map(function ($comment) {
                    return [
                        'id' => $comment->id,
                        'komment' => $comment->komment,
                        'letrehozas_datuma' => $comment->letrehozas_datuma,
                        'felhasznalo' => $comment->felhasznalo ? [
                            'felhasz_nev' => $comment->felhasznalo->felhasz_nev,
                        ] : null,
                        'gyermekKommentek' => []
                    ];
                });

            return response()->json($comments);
            */

        } catch (\Exception $e) {
            Log::error('Error in KommentController@index: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function store(Request $request, $postId)
    {
        try {
            $request->validate([
                'komment' => 'required|string|min:3|max:1000',
            ]);

            // For now, create without auth
            $comment = Kommentek::create([
                'komment' => $request->komment,
                'poszt_id' => $postId,
                'kommentelo' => 1, // Default user
                'letrehozas_datuma' => now(),
            ]);

            return response()->json([
                'message' => 'Comment added!',
                'comment' => [
                    'id' => $comment->id,
                    'komment' => $comment->komment,
                    'felhasznalo' => ['felhasz_nev' => 'You']
                ]
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
            $comment->delete();
            return response()->json(['message' => 'Comment deleted!']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}