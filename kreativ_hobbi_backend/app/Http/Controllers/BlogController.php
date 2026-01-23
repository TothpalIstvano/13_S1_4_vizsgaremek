<?php

namespace App\Http\Controllers;

use App\Models\Posztok;
use App\Models\Kommentek;
use Illuminate\Http\Request;

class BlogController extends Controller
{
    public function index()
    {
        $posztok = Posztok::with(['foKep', 'cimkek'])
            ->where('statusz', 'közzétett')
            ->orderBy('letrehozas_datuma', 'desc')
            ->get()
            ->map(function ($post) {
                return [
                    'id' => $post->id,
                    'cim' => $post->cim,
                    'kivonat' => $post->kivonat,
                    'letrehozas_datuma' => $post->letrehozas_datuma ? $post->letrehozas_datuma->format('d M Y') : 'N/A',
                    'fo_kep' => $post->foKep ? $post->foKep->url_Link : null,
                    'cimkek' => $post->cimkek->pluck('nev')->toArray(),
                    'szerző' => $post->szerzo ? $post->szerzo->felhasz_nev : 'Ismeretlen',
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
            'fo_kep' => $post->foKep ? $this->getImageUrl($post->foKep->url_Link) : null,
            'kepek' => $post->kepek->map(function ($image) {
                return [
                    'url' => $this->getImageUrl($image->url_Link),
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

    /**
     * Helper method to handle both local and external URLs
     */
    private function getImageUrl($url)
    {
        if (!$url) {
            return null;
        }

        // If it's already a full URL (http/https), return as is
        if (str_starts_with($url, 'http://') || str_starts_with($url, 'https://')) {
            return $url;
        }

        // If it's a local path, prepend storage path
        if (str_starts_with($url, 'blog/')) {
            return asset('storage/' . $url);
        }

        // Default fallback
        return asset('storage/' . $url);
    }

    public function main()
    {
        $posts = Posztok::with('cimkek:id,nev', 'foKep:id,url_Link,alt_szoveg')->where('statusz', 'közzétett')
            ->orderBy('created_at', 'desc')
            ->take(3)
            ->get();
        return response()->json(data: $posts);
    }
}