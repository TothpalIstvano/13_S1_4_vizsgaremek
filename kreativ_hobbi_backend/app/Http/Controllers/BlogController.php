<?php

namespace App\Http\Controllers;

use App\Models\Posztok;
use App\Models\PosztReakciok;
use App\Models\Kommentek;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class BlogController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        $userId = $user ? $user->id : null;

        $posztok = Posztok::with(['foKep', 'cimkek'])
            ->where('statusz', 'közzétett')
            ->orderBy('letrehozas_datuma', 'desc')
            ->withCount(['likedBy as likes_count', 'dislikedBy as dislikes_count'])
            ->get()
            ->map(function ($post) use ($userId) {
                $userReaction = null;
                if ($userId) {
                    $reaction = $post->reakciok()
                        ->where('felhasznalo_id', $userId)
                        ->first();
                    $userReaction = $reaction ? $reaction->reakcio : null;
                }

                return [
                    'id' => $post->id,
                    'cim' => $post->cim,
                    'kivonat' => $post->kivonat,
                    'letrehozas_datuma' => $post->letrehozas_datuma ? $post->letrehozas_datuma->format('d M Y') : 'N/A',
                    'fo_kep' => $post->foKep ? $post->foKep->url_Link : null,
                    'cimkek' => $post->cimkek->pluck('nev')->toArray(),
                    'szerző' => $post->szerzo ? $post->szerzo->felhasz_nev : 'Ismeretlen',
                    'statusz' => $post->statusz,
                    'likes_count' => $post->likes_count,
                    'dislikes_count' => $post->dislikes_count,
                    'userReaction' => $userReaction,
                ];
            });

        return response()->json($posztok);
    }

    public function show($id)
    {
        $post = Posztok::with(['foKep', 'cimkek', 'szerzo', 'kepek'])
            ->where('id', $id)
            ->where('statusz', 'közzétett')
            ->firstOrFail();

        return response()->json([
            'id' => $post->id,
            'cim' => $post->cim,
            'tartalom' => $post->tartalom,
            'kivonat' => $post->kivonat,
            'letrehozas_datuma' => $post->letrehozas_datuma ? $post->letrehozas_datuma->format('d M Y') : 'N/A',
            'fo_kep' => $post->foKep ? $post->foKep->url_Link : null,
            'kepek' => $post->kepek->map(function ($image) {
                return [
                    'url' => $image->url_Link,
                    'alt' => $image->alt_Szoveg,
                    'leiras' => $image->leiras,
                ];
            })->toArray(),
            'cimkek' => $post->cimkek->pluck('nev')->toArray(),
            'szerzo' => $post->szerzo ? $post->szerzo->felhasz_nev : 'Ismeretlen',
            'szerzo_id' => $post->szerzo_id,
            'kommentek_szama' => $post->kommentek()->count(),
        ]);
    }

    public function main()
    {
        $posts = Posztok::with('cimkek:id,nev', 'foKep:id,url_Link,alt_szoveg')->where('statusz', 'közzétett')
            ->orderBy('created_at', 'desc')
            ->take(3)
            ->get();
        return response()->json(data: $posts);
    }

    public function destroy($id)
    {
        try {
            $poszt = Posztok::findOrFail($id);
            \DB::table('posztcimkek')->where('poszt_id', $id)->delete();
            \DB::table('posztkepek')->where('poszt_id', $id)->delete();
            \DB::table('kommentek')->where('poszt_id', $id)->delete();
            \DB::table('posztreakciok')->where('poszt_id', $id)->delete();
            $poszt->delete();
            return response()->json(['message' => 'Bejegyzés törölve']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'cim' => 'required|string',
                'tartalom' => 'required|string',
                'kivonat' => 'nullable|string',
                'statusz' => 'nullable|string',
            ]);

            $poszt = new Posztok();
            $poszt->cim = $validated['cim'];
            $poszt->tartalom = $validated['tartalom'];
            $poszt->kivonat = $validated['kivonat'] ?? substr(strip_tags($validated['tartalom']), 0, 200);
            $poszt->statusz = $validated['statusz'] ?? 'piszkozat';
            $poszt->szerzo_id = auth()->id();
            $poszt->letrehozas_datuma = now();
            $poszt->save();

            return response()->json($poszt, 201);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }


    public function update(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'cim' => 'required|string',
                'tartalom' => 'required|string',
                'kivonat' => 'nullable|string',
                'statusz' => 'nullable|string',
            ]);

            $poszt = Posztok::findOrFail($id);

            $poszt->cim = $validated['cim'];
            $poszt->tartalom = $validated['tartalom'];
            $poszt->kivonat = $validated['kivonat'] ?? substr(strip_tags($validated['tartalom']), 0, 200);
            $poszt->statusz = $validated['statusz'] ?? 'piszkozat';

            $poszt->save();

            return response()->json($poszt, 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function userReactions(Request $request)
    {
        $userId = auth()->id();
        $reactions = PosztReakciok::where('felhasznalo_id', $userId)
            ->get(['poszt_id', 'reakcio']);

        return response()->json(
            $reactions->pluck('reakcio', 'poszt_id')
        );
    }

    public function reaction(Request $request, $id)
    {
        $request->validate([
            'reaction' => 'required|in:like,dislike'
        ]);

        $userId = auth()->id();
        $post = Posztok::findOrFail($id);

        $reaction = PosztReakciok::updateOrCreate(
            [
                'poszt_id' => $post->id,
                'felhasznalo_id' => $userId,
            ],
            [
                'reakcio' => $request->reaction
            ]
        );

        $likesCount = PosztReakciok::where('poszt_id', $post->id)
            ->where('reakcio', 'like')
            ->count();
        $dislikesCount = PosztReakciok::where('poszt_id', $post->id)
            ->where('reakcio', 'dislike')
            ->count();

        $userReaction = PosztReakciok::where('poszt_id', $post->id)
            ->where('felhasznalo_id', $userId)
            ->value('reakcio');

        return response()->json([
            'likes_count' => $likesCount,
            'dislikes_count' => $dislikesCount,
            'user_reaction' => $userReaction,
        ]);
    }

}