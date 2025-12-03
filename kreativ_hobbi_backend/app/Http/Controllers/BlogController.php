<?php

namespace App\Http\Controllers;

use App\Models\Posztok;
use Illuminate\Http\Request;

class BlogController extends Controller
{
    public function index()
    {
        $posts = Posztok::with(['foKep', 'cimkek'])
            ->where('statusz', 'közzétett')
            ->orderBy('letrehozas_datuma', 'desc')
            ->get()
            ->map(function ($post) {
                return [
                    'id' => $post->id,
                    'title' => $post->cim,
                    'excerpt' => $post->kivonat,
                    'created_at' => $post->letrehozas_datuma ? $post->letrehozas_datuma->format('d M Y') : 'N/A',
                    'main_image' => $post->foKep ? $post->foKep->url_Link : null,
                    'tags' => $post->cimkek->pluck('nev')->toArray(),
                    'author' => $post->szerzo ? $post->szerzo->felhasz_nev : 'Ismeretlen',
                ];
            });

        return response()->json($posts);
    }

    public function show($id)
    {
        $post = Posztok::with(['foKep', 'cimkek', 'szerzo', 'kepek'])
            ->where('id', $id)
            ->where('statusz', 'közzétett')
            ->firstOrFail();

        return response()->json([
            'id' => $post->id,
            'title' => $post->cim,
            'content' => $post->tartalom,
            'excerpt' => $post->kivonat,
            'created_at' => $post->letrehozas_datuma ? $post->letrehozas_datuma->format('d M Y') : 'N/A',
            'main_image' => $post->foKep ? $post->foKep->url_Link : null,
            'images' => $post->kepek->map(function ($image) {
                return [
                    'url' => $image->url_Link,
                    'alt' => $image->alt_Szoveg,
                    'description' => $image->leiras,
                ];
            })->toArray(),
            'tags' => $post->cimkek->pluck('nev')->toArray(),
            'author' => $post->szerzo ? $post->szerzo->felhasz_nev : 'Ismeretlen',
            'author_id' => $post->szerzo_id,
        ]);
    }
}