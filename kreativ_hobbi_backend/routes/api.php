<?php

use App\Models\TermekKategoriak;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BlogController;
use App\Http\Controllers\KommentController;
use App\Http\Controllers\ImageController;
use App\Http\Controllers\FelhasznaloController;
use App\Http\Controllers\PosztController;
use App\Models\FelhasznaloAdatok;
use App\Models\Posztok;
use App\Models\Termekek;
use App\Models\Rendelesek;
use App\Models\RendeltTermekek;
use App\Models\Cimkek;
use App\Models\Felhasznalok;
use Illuminate\Support\Facades\Auth;
use App\Models\Kategoriak;
use App\Models\Varosok;

//User related API routes:


// Check if user is logged in and return szerepkor
Route::get('/user/check', function () {
    if (Auth::check()) {
        $adatok = FelhasznaloAdatok::find(auth()->user()->id);
        if (!$adatok) {
            return response()->json(['loggedIn' => true, 'szerepkor' => null], 200);
        }
        return response()->json(['loggedIn' => true, 'szerepkor' => $adatok->szerepkor], 200);
    }
    return response()->json(['loggedIn' => false], 200);
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
        return Varosok::select('id', 'varos_nev', 'iranyitoszam')
            ->orderBy('varos_nev')
            ->get();
    });

    Route::post('/posts', [PosztController::class, 'store']);
    Route::get('/posts/{id}/edit', [PosztController::class, 'edit']);
    Route::put('/posts/{id}', [PosztController::class, 'update']);
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

Route::get('/termekek', function () {
    $termekek = Termekek::with('TermekKategoria', 'TermekFoKep', 'TermekSzinek', 'TermekKategoriak')
        ->get(['id', 'nev', 'ar', 'leiras', 'darab', 'meter', 'kategoria_id', 'fo_kep_id']);
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
    if ($validated == false) {
        return response()->json(['error' => 'Validation failed'], 422);
    } else {
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

// Admin routes
Route::middleware(['auth:sanctum'])->prefix('admin')->group(function () {

    // Stats
    Route::get('/stats', function () {
        return response()->json([
            'totalSales'     => Rendelesek::sum('osszeg'),
            'totalOrders'    => Rendelesek::count(),
            'totalProducts'  => Termekek::count(),
            'totalCustomers' => Felhasznalok::count(),
        ]);
    });

    // Analytics
    Route::get('/analytics', function () {
        try {
            $monthlySales = Rendelesek::selectRaw('MONTH(rendeles_datuma) as honap, SUM(osszeg) as osszeg')
                ->whereYear('rendeles_datuma', now()->year)
                ->groupBy('honap')
                ->orderBy('honap')
                ->pluck('osszeg');

            $monthlyOrders = Rendelesek::selectRaw('MONTH(rendeles_datuma) as honap, COUNT(*) as db')
                ->whereYear('rendeles_datuma', now()->year)
                ->groupBy('honap')
                ->orderBy('honap')
                ->pluck('db');

            $categories = Kategoriak::withCount('termekek')->get()
                ->map(fn($k) => ['nev' => $k->nev, 'db' => $k->termekek_count]);

            return response()->json([
                'monthlySales'  => $monthlySales,
                'monthlyOrders' => $monthlyOrders,
                'categories'    => $categories,
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage(), 'line' => $e->getLine()], 500);
        }
    });

    // Rendelések lista
    Route::get('/rendelesek', function () {
        $rendelesek = Rendelesek::with('felhasznalo:id,felhasz_nev')
            ->withCount('rendeltTermekek')
            ->orderBy('rendeles_datuma', 'desc')
            ->get()
            ->map(fn($r) => [
                'id'              => 'ORD-' . $r->id,
                'felhasznalo'     => ['nev' => $r->felhasznalo?->felhasz_nev ?? 'Vendég'],
                'termekek_szama'  => $r->rendelt_termekek_count,
                'osszeg'          => $r->osszeg,
                'statusz'         => $r->statusz,
                'rendeles_datuma' => $r->rendeles_datuma,
            ]);

        return response()->json($rendelesek);
    });

    // Rendelés státusz frissítés
    Route::patch('/rendelesek/{id}/statusz', function (Request $request, $id) {
        $request->validate(['statusz' => 'required|string']);

        $rendeles = Rendelesek::findOrFail($id);
        $rendeles->statusz = $request->statusz;
        $rendeles->save();

        return response()->json(['message' => 'Statusz frissítve', 'statusz' => $rendeles->statusz]);
    });

    // Termékek CRUD
    Route::post('/termekek', function (Request $request) {
        $validated = $request->validate([
            'nev'          => 'required|string',
            'kategoria_id' => 'required|integer|exists:kategoriak,id',
            'ar'           => 'required|integer|min:0',
            'darab'        => 'required|integer|min:0',
            'leiras'       => 'nullable|string',
            'fo_kep_id'    => 'nullable|integer',
        ]);

        $termek = Termekek::create($validated);
        return response()->json($termek->load('TermekKategoria', 'TermekFoKep'), 201);
    });

    Route::put('/termekek/{id}', function (Request $request, $id) {
        $termek = Termekek::findOrFail($id);

        $validated = $request->validate([
            'nev'          => 'sometimes|string',
            'kategoria_id' => 'sometimes|integer|exists:kategoriak,id',
            'ar'           => 'sometimes|integer|min:0',
            'darab'        => 'sometimes|integer|min:0',
            'leiras'       => 'nullable|string',
            'fo_kep_id'    => 'nullable|integer',
        ]);

        $termek->update($validated);
        return response()->json($termek->load('TermekKategoria', 'TermekFoKep'));
    });

    Route::delete('/termekek/{id}', function ($id) {
        try {
            \DB::table('kedvencek')->where('termek_id', $id)->delete();
            \DB::table('rendelttermekek')->where('termek_id', $id)->delete();
            \DB::table('termekkategoriak')->where('termek_id', $id)->delete();
            \DB::table('termekszinek')->where('termek_id', $id)->delete();
            \DB::table('termekkepek')->where('termek_id', $id)->delete();

            Termekek::findOrFail($id)->delete();
            return response()->json(['message' => 'Termék törölve']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    });
    // Blog CRUD
    Route::post('/blog', [BlogController::class, 'store']);
    Route::put('/blog/{id}', [BlogController::class, 'update']);
    Route::delete('/blog/{id}', [BlogController::class, 'destroy']);
});