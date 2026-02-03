<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BlogController;
use App\Http\Controllers\KommentController;
use App\Http\Controllers\ImageController;
use App\Models\Posztok;
use App\Models\Termekek;
use App\Models\Rendelesek;
use App\Models\RendeltTermekek;
use App\Models\Cimkek;
use App\Models\Felhasznalok;

//User related API routes:

// Get authenticated user
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Check if user is logged in
Route::get('/user/check', function () {
    if (Auth::check()) {
        return response()->json(['loggedIn' => true, 'user' => auth()->user()], 200);
    } else {
        return response()->json(['loggedIn' => false], 200);
    }
});

// Get posts of authenticated user
Route::get('/user/posts', function () {
    if (Auth::check()) {
        $user = auth()->user();
        $posts = Posztok::with('cimkek:id,nev', 'foKep:id,url_Link,alt_szoveg')
            ->where('szerzo_id', $user->id)
            ->get()
            ->map(function ($post) {
                // Transform the post to ensure fo_kep has default values if null
                $postArray = $post->toArray();

                // If fo_kep is null, set default values
                if (!$post->foKep) {
                    $postArray['fo_kep'] = [
                        'url_Link' => 'profilKepek/default.jpg',
                        'alt_szoveg' => $post->cim
                    ];
                }

                return $postArray;
            });
        return response()->json(data: $posts);
    } else {
        return response()->json(['error' => 'Unauthorized'], 401);
    }
});

// Image upload routes
Route::post('/upload-images', [ImageController::class, 'upload'])->middleware('auth:sanctum');

// API routes for blog and comments:

//Blog posts on main page:
Route::get('/blog/main', [BlogController::class, 'main']);

// Blog routes
Route::get('/blog', [BlogController::class, 'index']);
Route::get('/blog/{id}', [BlogController::class, 'show']);

// Comment routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/blog/{id}/comments', [KommentController::class, 'store']);
    Route::delete('/comments/{id}', [KommentController::class, 'destroy']);
});
Route::get('/blog/{id}/comments', [KommentController::class, 'index']);

// Címkék az új poszthoz
Route::get('/cimkek', function () {
    $cimkek = Cimkek::select('id', 'nev')->get();
    return response()->json($cimkek);
});

/* Reakciók a poszthoz
Route::middleware('web')->group(function () {
    Route::post('/blog/{id}/reaction', function (Request $request, $id) {
        $user = Auth::user();
        $reaction = $request->input('reaction');

        if (!in_array($reaction, ['like', 'dislike'])) {
            return response()->json(['error' => 'Invalid reaction'], 400);
        }

        $post = Posztok::find($id);
        if (!$post) {
            return response()->json(['error' => 'Post not found'], 404);
        }

        $existingReaction = PosztReakciok::where('poszt_id', $id)
            ->where('felhasznalo_id', $user->id)
            ->first();

        if ($existingReaction) {
            if ($existingReaction->reakcio === $reaction) {
                $existingReaction->delete();
                $message = 'Reaction removed';
            } else {
                $existingReaction->reakcio = $reaction;
                $existingReaction->save();
                $message = 'Reaction updated';
            }
        } else {
            PosztReakciok::create([
                'poszt_id' => $id,
                'felhasznalo_id' => $user->id,
                'reakcio' => $reaction
            ]);
            $message = 'Reaction added';
        }

        $likesCount = $post->likedBy()->count();
        $dislikesCount = $post->dislikedBy()->count();

        return response()->json([
            'message' => $message,
            'likes_count' => $likesCount,
            'dislikes_count' => $dislikesCount,
            'user_reaction' => $existingReaction ? $existingReaction->reakcio : null
        ]);
    });

    Route::get('/user/reactions', function () {
        $user = Auth::user();
        $reactions = PosztReakciok::where('felhasznalo_id', $user->id)
            ->get()
            ->pluck('reakcio', 'poszt_id');

        return response()->json($reactions);
    });
});

 Reakciók száma
Route::middleware('web')->get('/user/check', function () {
    if (Auth::check()) {
        return response()->json(['loggedIn' => true, 'user' => auth()->user()], 200);
    } else {
        return response()->json(['loggedIn' => false], 200);
    }
});*/

// Új poszt
Route::post('/posts', function (Request $request) {
    if (!Auth::check()) {
        return response()->json(['error' => 'Unauthorized'], 401);
    }

    \Log::info('Post creation request:', $request->all());

    $validated = $request->validate([
        'title' => 'required|string|max:255',
        'content' => 'required|string',
        'kivonat' => 'nullable|string|max:255',
        'tags' => 'nullable|array',
        'images' => 'nullable|array',
        'images.*.id' => 'nullable|integer|exists:kepek,id',
        'images.*.alt' => 'nullable|string|max:255',
        'images.*.description' => 'nullable|string|max:255',
    ]);

    $user = Auth::user();

    $post = new Posztok();
    $post->cim = $validated['title'];
    $post->tartalom = $validated['content'];
    $post->kivonat = $validated['kivonat'] ?? substr(strip_tags($validated['content']), 0, 200);
    $post->szerzo_id = $user->id;
    $post->statusz = 'közzétett';

    $saved = $post->save();

    if (!$saved) {
        return response()->json(['error' => 'Failed to save post'], 500);
    }

    if ($request->has('tags') && is_array($request->tags) && count($request->tags) > 0) {
        try {
            $post->cimkek()->attach($request->tags);
            \Log::info('Tags attached:', $request->tags);
        } catch (\Exception $e) {
            \Log::error('Failed to attach tags: ' . $e->getMessage());
        }
    }

    if ($request->has('images') && is_array($request->images) && count($request->images) > 0) {
        try {
            $imageIds = array_column($request->images, 'id');
            $post->kepek()->attach($imageIds);

            if (!empty($imageIds)) {
                $post->fo_kep_id = $imageIds[0];
                $post->save();
            }
        } catch (\Exception $e) {
            \Log::error('Failed to attach images: ' . $e->getMessage());
        }
    }

    return response()->json([
        'message' => 'Post created successfully',
        'post' => $post->load('cimkek')
    ], 201);
})->middleware('auth:sanctum');

Route::get('/termekek', function () {
    $termekek = Termekek::all('id', 'nev', 'ar', 'leiras', 'darab', 'meter', 'kategoria_id', 'fo_kep_id')->load('TermekKategoria', 'TermekFoKep', 'TermekSzinek', 'TermekCimkek');
    return response()->json($termekek);
});

Route::get('/termekek/{id}', function ($id) {
    try {
        $termek = Termekek::with('TermekKategoria', 'TermekFoKep', 'TermekSzinek', 'TermekCimkek')->find($id);
        if ($termek) {
            return response()->json($termek);
        } else {
            return response()->json(['error' => 'Termék nem található'], 404);
        }
    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
});

Route::post('/rendeles', function (Request $request) {
    $validated = $request->validate([
        'felhasznalo_id' => 'nullable|exists:felhasznalok,id',
        'termekek' => 'required|array|min:1',
        'termekek.*.termek_id' => 'required|integer|exists:termekek,id',
        'termekek.*.mennyiseg' => 'required|integer|min:1',
        'termekek.*.szin_id' => 'nullable|integer|exists:szinek,id'
    ]);

    // Determine user: authenticated > provided felhasznalo_id > fallback to a shared guest account
    $userId = Auth::check() ? auth()->id() : ($validated['felhasznalo_id'] ?? null);
    if (!$userId) {
        \Log::info('No user supplied for rendelés, using or creating a guest user');
        $guest = Felhasznalok::firstOrCreate(
            ['email' => 'guest@local'],
            ['felhasz_nev' => 'guest', 'jelszo' => \Illuminate\Support\Str::random(12)]
        );
        $userId = $guest->id;
    }

    try {
        \DB::beginTransaction();

        // Recompute total and validate stock under lock
        $total = 0;
        foreach ($validated['termekek'] as $t) {
            $p = Termekek::lockForUpdate()->find($t['termek_id']);
            if (!$p) {
                \DB::rollBack();
                return response()->json(['message' => "Product {$t['termek_id']} not found"], 404);
            }
            if ($p->darab < $t['mennyiseg']) {
                \DB::rollBack();
                return response()->json(['message' => "Not enough stock for {$p->nev}"], 422);
            }
            $total += $p->ar * $t['mennyiseg'];
        }

        $rendeles = new Rendelesek();
        $rendeles->felhasznalo_id = $userId;
        $rendeles->osszeg = $total;
        $rendeles->statusz = 'függőben';
        $rendeles->rendeles_datuma = now();
        $rendeles->save();

        foreach ($validated['termekek'] as $termek) {
            $p = Termekek::lockForUpdate()->find($termek['termek_id']);

            $rt = new RendeltTermekek();
            $rt->rendeles_id = $rendeles->id;
            $rt->termek_id = $termek['termek_id'];
            $rt->mennyiseg = $termek['mennyiseg'];
            $rt->egysegar = $p->ar;
            $rt->szin_id = $termek['szin_id'] ?? null;
            $rt->save();

            $p->darab -= $termek['mennyiseg'];
            $p->save();
        }

        \DB::commit();
        return response()->json(['message' => 'Rendelés sikeresen létrehozva', 'rendeles_id' => $rendeles->id], 201);
    } catch (\Exception $e) {
        \DB::rollBack();
        \Log::error('Rendeles creation failed', [
            'message' => $e->getMessage(),
            'payload' => $request->all(),
            'trace' => $e->getTraceAsString(),
        ]);
        return response()->json(['message' => 'Server error'], 500);
    }
});

Route::get('/carousel/termekek', function () {
    $termekek = Termekek::select('id','darab', 'nev', 'ar', 'fo_kep_id','leiras', 'updated_at')
        ->with('TermekFoKep')
        ->where('darab', '>', 0)
        ->orderBy('updated_at', 'desc')
        ->orderBy('darab', 'desc')
        ->take(5)
        ->get()
        ->toArray();
    return response()->json($termekek);
});

Route::get('/termekek/fonal-csoport/{fonalTipus}', function ($fonalTipus) {
    try {
        // Clean the fonalTipus parameter to match your data structure
        $cleanFonalTipus = str_replace(' fonal csoport', '', $fonalTipus);

        // Find products that match the fonal type
        // Adjust this query based on your actual database structure
        $termekek = Termekek::with('TermekKategoria', 'TermekFoKep', 'TermekSzinek', 'TermekCimkek')
            ->whereHas('TermekKategoria', function ($query) use ($cleanFonalTipus) {
                $query->where('nev', 'like', '%' . $cleanFonalTipus . '%')
                    ->orWhere('leiras', 'like', '%' . $cleanFonalTipus . '%');
            })
            ->orWhere('nev', 'like', '%' . $cleanFonalTipus . '%')
            ->orWhere('leiras', 'like', '%' . $cleanFonalTipus . '%')
            ->get();

        if ($termekek->isEmpty()) {
            // If no direct match, return empty array
            return response()->json([]);
        }

        return response()->json($termekek);
    } catch (\Exception $e) {
        \Log::error('Fonal termék betöltése sikertelen: ' . $e->getMessage());
        return response()->json(['error' => $e->getMessage()], 500);
    }
});

// Add cart endpoint
Route::post('/kosar/hozzaad', function (Request $request) {
    $validated = $request->validate([
        'termek_id' => 'required|integer|exists:termekek,id',
        'mennyiseg' => 'required|integer|min:1',
        'user_id' => 'nullable|integer'
    ]);

    try {
        // Check if product exists and has enough stock
        $termek = Termekek::find($validated['termek_id']);

        if (!$termek) {
            return response()->json(['error' => 'Termék nem található'], 404);
        }

        if ($termek->darab < $validated['mennyiseg']) {
            return response()->json(['error' => 'Nincs elegendő készlet'], 422);
        }

        // In a real application, you'd save to session or database cart
        // For now, we'll return success
        return response()->json([
            'message' => 'Termék sikeresen hozzáadva a kosárhoz',
            'termek' => $termek,
            'mennyiseg' => $validated['mennyiseg'],
            'osszeg' => $termek->ar * $validated['mennyiseg']
        ], 200);

    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
});