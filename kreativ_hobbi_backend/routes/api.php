<?php

use App\Models\TermekKategoriak;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BlogController;
use App\Http\Controllers\KommentController;
use App\Http\Controllers\ImageController;
use App\Http\Controllers\FelhasznaloController;
use App\Models\Posztok;
use App\Models\Termekek;
use App\Models\Rendelesek;
use App\Models\RendeltTermekek;
use App\Models\Cimkek;
use App\Models\Felhasznalok;
use Illuminate\Support\Facades\Auth;
use App\Models\Kategoriak;

//User related API routes:


// Check if user is logged in
Route::get('/user/check', function () {
    if (Auth::check()) {
        return response()->json(['loggedIn' => true], 200);
    } else {
        return response()->json(['loggedIn' => false], 200);
    }
});

Route::middleware('auth:sanctum')->group(function () {
    // existing routes
    Route::get('/user', function (Request $request) {
        return $request->user()->load('profilKep:id,url_Link,alt_szoveg', 'adatok')->toArray();
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

    // Update user profile
    Route::put('/user/profile', [FelhasznaloController::class, 'updateProfile']);

    // Update profile picture ID
    Route::put('/user/profile-picture', [FelhasznaloController::class, 'updateProfilePicture']);

    Route::get('/cities', function () {
        return App\Models\Varosok::select('id', 'varos_nev', 'iranyitoszam')
            ->orderBy('varos_nev')
            ->get();
    });
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

Route::get('/termekek/kategoriak', function () {
    $kategoriak = Kategoriak::select('id', 'nev', 'fo_kategoria_id')->get();
    return response()->json($kategoriak);
});

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
    $termekek = Termekek::all('id', 'nev', 'ar', 'leiras', 'darab', 'meter', 'kategoria_id', 'fo_kep_id')->load('TermekKategoria', 'TermekFoKep', 'TermekSzinek', 'TermekKategoriak');
    return response()->json($termekek);
});

Route::get('/termekek/{id}', function ($id) {
    try {
        $termek = Termekek::with('TermekKategoria', 'TermekFoKep', 'TermekSzinek', 'TermekKategoriak')->find($id);
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
    if($validated == false) {
        return response()->json(['error' => 'Validation failed'], 422);
    }
    else {
        response()->json(['message' => 'Validation passed'], 200);
    }

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
    $termekek = Termekek::select('id', 'darab', 'nev', 'ar', 'fo_kep_id', 'leiras', 'updated_at')
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
        $fonalTipus = str_replace(' fonal csoport', '', $fonalTipus);

        $fonalMapping = [
            'A fonal csoport' => 'A fonal',
            'B fonal csoport' => 'B fonal',
            'C fonal csoport' => 'C fonal',
            'D fonal csoport' => 'D fonal',
            'E fonal csoport' => 'E fonal'
        ];

        $searchTerm = $fonalMapping[$fonalTipus] ?? substr($fonalTipus, 0, 1);

        $termekek = Termekek::with([
            'TermekKategoria',
            'TermekFoKep',
            'TermekSzinek' => function ($query) {
                $query->select('szinek.id', 'szinek.hex_kod', 'szinek.nev as szin_nev');
            },
            'TermekKategoriak'
        ])
            ->where(function ($query) use ($searchTerm, $fonalTipus) {
                $query->whereHas('TermekKategoria', function ($q) use ($searchTerm, $fonalTipus) {
                    $q->where('nev', '=', $fonalTipus)
                        ->orWhere('nev', 'like', $searchTerm . '%')
                        ->orWhere('nev', 'like', '%' . $fonalTipus . '%');
                })
                    ->orWhere('nev', '=', $fonalTipus)
                    ->orWhere('nev', 'like', $searchTerm . '%')
                    ->orWhere('nev', 'like', '%' . $fonalTipus . '%');
            })
            ->get();

        if ($termekek->count() > 1) {
            $termekek = $termekek->filter(function ($termek) use ($searchTerm) {
                $name = strtolower($termek->nev);
                $search = strtolower($searchTerm);

                return strpos($name, $search . ' ') === 0 ||
                    strpos($name, $search . ' fonal') !== false ||
                    strpos($name, 'fonal ' . $search) !== false;
            })->values();
        }

        $termekek->each(function ($termek) {
            $termek->available_colors = $termek->TermekSzinek->map(function ($szin) {
                return [
                    'hex' => $szin->hex_kod,
                    'name' => $szin->szin_nev
                ];
            });
        });

        if ($termekek->isEmpty()) {
            return response()->json([]);
        }

        return response()->json($termekek);
    } catch (\Exception $e) {
        \Log::error('Fonal termék betöltése sikertelen: ' . $e->getMessage());
        return response()->json(['error' => $e->getMessage()], 500);
    }
});

// Kosárhoz adás mintakészítőből
Route::post('/kosar/hozzaad', function (Request $request) {
    $validated = $request->validate([
        'termek_id' => 'required|integer|exists:termekek,id',
        'mennyiseg' => 'required|integer|min:1',
        'user_id' => 'nullable|integer'
    ]);

    try {
        $termek = Termekek::find($validated['termek_id']);

        if (!$termek) {
            return response()->json(['error' => 'Termék nem található'], 404);
        }

        if ($termek->darab < $validated['mennyiseg']) {
            return response()->json(['error' => 'Nincs elegendő készlet'], 422);
        }

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