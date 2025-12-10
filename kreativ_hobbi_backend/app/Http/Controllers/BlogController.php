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
}