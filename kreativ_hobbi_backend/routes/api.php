<?php

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
use App\Mail\RendelesVisszaigazolas;
use Illuminate\Support\Facades\Mail;
use App\Models\Szinek;
//User related API routes:

// Check if user is logged in and return szerepkor
Route::get('/user/check', function () {
    if (Auth::check()) {
        $adatok = FelhasznaloAdatok::find(auth()->user()->id);
        if (!$adatok) {
            return response()->json(['loggedIn' => true, 'szerepkor' => null, 'id' => auth()->user()->id], 200);
        }
        return response()->json(['loggedIn' => true, 'szerepkor' => $adatok->szerepkor], 200);
    }
    return response()->json(['loggedIn' => false], 200);
});

Route::post('/login', function (Request $request) {
    if (!Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
        return response()->json(['message' => 'Hibás adatok'], 401);
    }
    return response()->json([
        'token' => $request->user()->createToken('postman')->plainTextToken
    ]);
});

Route::middleware('auth:sanctum')->post('/logout', function (Request $request) {
    $request->user()->currentAccessToken()->delete();
    return response()->json(['message' => 'Kijelentkezve']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user()
            ->load(
                'profilKep:id,url_Link,alt_szoveg',
                'hatterKep:id,url_Link',
                'adatok:felhasznalo_id,vezeteknev,keresztnev,szerepkor,varos,utca,hazszam,emeletAjto,telefonszam'
            )
            ->only(['id', 'felhasz_nev', 'email', 'email_verified_at', 'profilKep', 'adatok', 'letrehozas_Datuma']);
    });

    Route::get('/user/navbar', function (Request $request) {
        return $request->user()
            ->load('profilKep:id,url_Link')
            ->only(['profilKep']);
    });

    // Get posts of authenticated user
    Route::get('/user/posts', function () {
        if (Auth::check()) {
            $user = auth()->user();
            $posts = Posztok::with('cimkek:id,nev', 'foKep:id,url_Link,alt_szoveg')
                ->where('szerzo_id', $user->id)
                ->get()
                ->map(function ($post) {
                    $postArray = $post->toArray();

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

    Route::put('/user/profile', [FelhasznaloController::class, 'updateProfile']);

    Route::put('/user/profile-picture', [FelhasznaloController::class, 'updateProfilePicture']);

    Route::put('/user/cover-picture', [FelhasznaloController::class, 'updateCoverPicture']);

    // Pre-seeded background images to pick from
    Route::get('/hatterkepek', function () {
        $kepek = \App\Models\Kepek::where('url_Link', 'like', '%hatterKepek%')
            ->orWhere('url_Link', 'like', '%hatterkepek%')
            ->get(['id', 'url_Link', 'alt_Szoveg']);
        return response()->json($kepek);
    });

    Route::post('/posts', [PosztController::class, 'store']);
    Route::get('/posts/{id}/edit', [PosztController::class, 'edit']);
    Route::put('/posts/{id}', [PosztController::class, 'update']);

    Route::get('/user/reactions', [BlogController::class, 'userReactions']);
    Route::post('/blog/{id}/reaction', [BlogController::class, 'reaction']);

    // Fetch the logged-in user's liked product IDs
    Route::get('/user/kedvencek', function (Request $request) {
        return $request->user()
            ->kedvencek()           // see model note below
            ->pluck('termek_id');
    });

    // Toggle like on a product
    Route::post('/termekek/{id}/kedvenc', function (Request $request, $id) {
        $user = $request->user();
        $exists = \DB::table('kedvencek')
            ->where('felhasznalo_id', $user->id)
            ->where('termek_id', $id)
            ->exists();

        if ($exists) {
            \DB::table('kedvencek')
                ->where('felhasznalo_id', $user->id)
                ->where('termek_id', $id)
                ->delete();
            return response()->json(['liked' => false]);
        }

        \DB::table('kedvencek')->insert([
            'felhasznalo_id' => $user->id,
            'termek_id' => $id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        return response()->json(['liked' => true]);
    });
});

Route::get('/user/kedvencek/termekek', function (Request $request) {
    return $request->user()
        ->kedvencek()
        ->with('termek.TermekFoKep')
        ->get()
        ->pluck('termek');
});

Route::get('/varosok', function () {
    return Varosok::select('id', 'varos_nev', 'iranyitoszam')
        ->orderBy('varos_nev')
        ->get();
});

// Image upload routes
Route::post('/upload-images', [ImageController::class, 'uploadBlogPictures'])->middleware('auth:sanctum');
Route::post('/upload-profile-picture', [ImageController::class, 'uploadProfilePicture'])->middleware('auth:sanctum');
Route::post('/upload-cover-picture', [ImageController::class, 'uploadCoverPicture'])->middleware('auth:sanctum');
Route::post('/upload-termekek-pictures', [ImageController::class, 'uploadTermekPictures'])->middleware('auth:sanctum');


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
    $termekek = Termekek::with(
        'TermekKategoria',
        'TermekFoKep',
        'TermekSzinek',
        'TermekKategoriak',
        'TermekKepek'     
    )
        ->get(['id', 'nev', 'ar', 'leiras', 'darab', 'meter', 'kategoria_id', 'fo_kep_id']);

    return response()->json($termekek);
});

Route::get('/termekek/{id}', function ($id) {
    try {
        $termek = Termekek::with('TermekKategoria', 'TermekFoKep', 'TermekSzinek', 'TermekKategoriak', 'TermekKepek')->find($id);
        if ($termek) {
            return response()->json($termek);
        } else {
            return response()->json(['error' => 'Termék nem található'], 404);
        }
    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
});

Route::get('/szinek', function () {
    return Szinek::select('id', 'nev', 'hex_kod')->orderBy('nev')->get();
});


Route::post('/rendeles', function (Request $request) {
    $validated = $request->validate([
        'delivery.name' => ['required', 'string', 'regex:/^[\p{L}\-]{2,}(\s[\p{L}\-]{2,}){0,3}$/u'],
        'delivery.email' => ['required', 'email:rfc'],
        'delivery.phone' => ['required', 'regex:/^[+]?[\d\s\-()]{9,15}$/'],
        'delivery.city_id' => ['required', 'integer', 'min:1', 'exists:varosok,id'],
        'delivery.utca' => ['required', 'string', 'min:3', 'max:255'],
        'delivery.hazszam' => ['required', 'integer', 'min:1'],
        'delivery.emeletAjto' => ['nullable', 'string', 'max:10'],
        'items' => ['required', 'array', 'min:1'],
        'items.*.id' => ['required', 'integer', 'exists:termekek,id'],
        'items.*.mennyiseg' => ['required', 'integer', 'min:1'],
        'items.*.szin_id' => ['nullable', 'integer', 'exists:szinek,id'],
    ]);

    try {
        \DB::beginTransaction();

        $total = 0;
        foreach ($validated['items'] as $item) {
            $p = Termekek::lockForUpdate()->find($item['id']);
            if (!$p) {
                \DB::rollBack();
                return response()->json(['message' => "Termék nem található: {$item['id']}"], 404);
            }
            if ($p->darab < $item['mennyiseg']) {
                \DB::rollBack();
                return response()->json(['message' => "Nincs elegendő készlet: {$p->nev}"], 422);
            }
            $total += $p->ar * $item['mennyiseg'];
        }

        // Város neve snapshot-hoz
        $varos = Varosok::find($validated['delivery']['city_id']);

        $rendeles = Rendelesek::create([
            'felhasznalo_id' => auth()->user()->id ?? null,
            'statusz' => 'függőben',
            'fizetes_statusz' => 'függőben',
            'osszeg' => $total,
            'szallitasi_nev' => $validated['delivery']['name'],
            'szallitasi_email' => $validated['delivery']['email'],
            'szallitasi_telefon' => $validated['delivery']['phone'],
            'szallitasi_utca' => $validated['delivery']['utca'],
            'szallitasi_hazszam' => $validated['delivery']['hazszam'],
            'szallitasi_emeletAjto' => $validated['delivery']['emeletAjto'],
            'szallitasi_varos_nev' => $varos->varos_nev,
            'szallitasi_varos_id' => $validated['delivery']['city_id'],
        ]);

        foreach ($validated['items'] as $item) {
            $p = Termekek::find($item['id']);

            RendeltTermekek::create([
                'rendeles_id' => $rendeles->id,
                'termek_id' => $item['id'],
                'mennyiseg' => $item['mennyiseg'],
                'egysegar' => $p->ar,
                'szin_id' => $item['szin_id'] ?? null,
            ]);

            $p->decrement('darab', $item['mennyiseg']);
        }

        \DB::commit();

        // Email visszaigazolás küldése
        try {
            $tetelek = collect($validated['items'])->map(function ($item) {
                $p = Termekek::find($item['id']);
                return [
                    'nev' => $p->nev,
                    'mennyiseg' => $item['mennyiseg'],
                    'egysegar' => $p->ar,
                ];
            })->toArray();

            Mail::to($validated['delivery']['email'])
                ->send(new RendelesVisszaigazolas(
                    $rendeles->fresh()->toArray(),
                    $tetelek
                ));
        } catch (\Exception $mailEx) {
            \Log::warning('Visszaigazoló email küldése sikertelen', [
                'rendeles_id' => $rendeles->id,
                'email' => $validated['delivery']['email'],
                'error' => $mailEx->getMessage(),
            ]);
        }

        return response()->json([
            'message' => 'Rendelés sikeresen létrehozva',
            'rendeles_id' => $rendeles->id
        ], 201);

    } catch (\Exception $e) {
        \DB::rollBack();
        \Log::error('Rendeles creation failed', ['message' => $e->getMessage(), 'line' => $e->getLine()]);
        return response()->json(['message' => $e->getMessage(), 'line' => $e->getLine()], 500);
    }
});

Route::get('/user/szallitasi-adatok', function (Request $request) {
    $adatok = $request->user()->adatok;
    if (!$adatok)
        return response()->json(null);

    return response()->json([
        'vezeteknev' => $adatok->vezeteknev,
        'keresztnev' => $adatok->keresztnev,
        'varos' => $adatok->varos,
        'utca' => $adatok->utca,
        'hazszam' => $adatok->hazszam,
        'emeletAjto' => $adatok->emeletAjto,
        'telefonszam' => $adatok->telefonszam,
        'email' => $request->user()->email
    ]);
});

Route::middleware('auth:sanctum')->post('/user/szallitasi-adatok-mentese', function (Request $request) {
    $validated = $request->validate([
        'vezeteknev' => ['required', 'string', 'max:100'],
        'keresztnev' => ['required', 'string', 'max:100'],
        'varos_id' => ['required', 'integer', 'exists:varosok,id'],
        'utca' => ['required', 'string', 'max:255'],
        'hazszam' => ['required', 'integer', 'min:1'],
        'emeletAjto' => ['nullable', 'string', 'max:10'],
        'telefonszam' => ['required', 'string', 'max:20'],
    ]);

    $adatok = FelhasznaloAdatok::firstOrNew(['felhasznalo_id' => auth()->id()]);
    $adatok->felhasznalo_id = auth()->id();
    $adatok->vezeteknev = $validated['vezeteknev'];
    $adatok->keresztnev = $validated['keresztnev'];
    $adatok->varos = $validated['varos_id'];
    $adatok->utca = $validated['utca'];
    $adatok->hazszam = $validated['hazszam'];
    $adatok->emeletAjto = $validated['emeletAjto'] ?? null;
    $adatok->telefonszam = $validated['telefonszam'];
    $adatok->save();

    return response()->json(['message' => 'Szállítási adatok mentve']);
});

// Kártyaadatok lekérése
Route::middleware('auth:sanctum')->get('/user/kartya-adatok', function (Request $request) {

    $adatok = $request->user()->adatok;

    if (!$adatok || !$adatok->kartyaszam) {
        return response()->json(null);
    }

    try {
        $kartyaszam = decrypt($adatok->kartyaszam);
        $masked = str_repeat('*', strlen($kartyaszam) - 4) . substr($kartyaszam, -4);
        $prefix = substr($kartyaszam, 0, 4);
        $prefix2 = substr($kartyaszam, 0, 2);
        $prefix1 = substr($kartyaszam, 0, 1);

        if (str_starts_with($kartyaszam, '34') || str_starts_with($kartyaszam, '37')) {
            $tipus = 'amex';
        } elseif ($prefix1 === '4') {
            $tipus = 'visa';
        } elseif (in_array($prefix2, ['51', '52', '53', '54', '55'])) {
            $tipus = 'mastercard';
        } elseif ($prefix === '6011') {
            $tipus = 'discover';
        } elseif (str_starts_with($kartyaszam, '9792')) {
            $tipus = 'troy';
        } else {
            $tipus = 'visa';
        }

    } catch (\Exception $e) {
        $kartyaszam = null;
    }

    $lejart = false;
    if ($adatok->kartya_ev && $adatok->kartya_honap) {
        $now = now();
        $lejart = $adatok->kartya_ev < $now->year ||
            ($adatok->kartya_ev == $now->year && $adatok->kartya_honap < $now->month);
    }
    return response()->json([
        'kartyaszam' => $masked,
        'kartya_tipus' => $tipus,
        'kartya_nev' => $adatok->kartya_nev,
        'kartya_honap' => $adatok->kartya_honap,
        'kartya_ev' => $adatok->kartya_ev,
        'lejart' => $lejart
    ]);
});

// Kártyaadatok mentése
Route::middleware('auth:sanctum')->post('/user/kartya-mentese', function (Request $request) {
    $validated = $request->validate([
        'kartyaszam' => ['nullable', 'string', 'min:13', 'max:19'],
        'kartya_nev' => ['required', 'string', 'max:100'],
        'kartya_honap' => ['required', 'integer', 'min:1', 'max:12'],
        'kartya_ev' => ['required', 'integer', 'min:' . date('Y')],
    ]);

    $adatok = FelhasznaloAdatok::firstOrNew(['felhasznalo_id' => auth()->id()]);
    $adatok->felhasznalo_id = auth()->id();
    if ($validated['kartyaszam']) {
        $adatok->kartyaszam = encrypt($validated['kartyaszam']);
    }
    $adatok->kartya_nev = $validated['kartya_nev'];
    $adatok->kartya_honap = $validated['kartya_honap'];
    $adatok->kartya_ev = $validated['kartya_ev'];
    $adatok->save();

    return response()->json(['message' => 'Kártyaadatok mentve']);
});

Route::patch('/rendelesek/{id}/fizetes_statusz', function (Request $request, $id) {
    $request->validate(['fizetes_statusz' => 'required|string|in:függőben,fizetve,sikertelen']);

    $rendeles = Rendelesek::findOrFail($id);
    $rendeles->fizetes_statusz = $request->fizetes_statusz;
    $rendeles->save();

    return response()->json(['message' => 'fizetes_statusz frissítve', 'fizetes_statusz' => $rendeles->statusz]);
});


Route::get('/carousel/termekek', function () {
    $termekek = Termekek::select('id', 'darab', 'nev', 'ar', 'fo_kep_id', 'leiras', 'updated_at')
        ->with([
            'TermekFoKep',
            'TermekSzinek' => function ($query) {
                $query->select('szinek.id', 'szinek.hex_kod', 'szinek.nev');
            }
        ])
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

    Route::get('/user/id', function (Request $request) {
        return response()->json(['id' => $request->user()->id]);
    });

    // Stats
    Route::get('/stats', function () {
        return response()->json([
            'totalSales' => Rendelesek::sum('osszeg'),
            'totalOrders' => Rendelesek::count(),
            'totalProducts' => Termekek::count(),
            'totalCustomers' => Felhasznalok::count(),
        ]);
    });

    // Analytics
    Route::get('/analytics', function () {
        try {
            $rawSales = Rendelesek::selectRaw('MONTH(rendeles_datuma) as honap, SUM(osszeg) as osszeg')
                ->whereYear('rendeles_datuma', now()->year)
                ->groupBy('honap')
                ->orderBy('honap')
                ->pluck('osszeg', 'honap');

            $rawOrders = Rendelesek::selectRaw('MONTH(rendeles_datuma) as honap, COUNT(*) as db')
                ->whereYear('rendeles_datuma', now()->year)
                ->groupBy('honap')
                ->orderBy('honap')
                ->pluck('db', 'honap');

            // 12 elemű, 0-indexelt tömbök — hiányzó hónapok = 0
            $monthlySales = collect(range(1, 12))->map(fn($m) => (int) ($rawSales[$m] ?? 0))->values();
            $monthlyOrders = collect(range(1, 12))->map(fn($m) => (int) ($rawOrders[$m] ?? 0))->values();

            $foKategoriak = Kategoriak::whereNull('fo_kategoria_id')
                ->with([
                    'alkategoriak' => function ($q) {
                        $q->withCount('termekek');
                    }
                ])
                ->withCount('termekek')
                ->get()
                ->map(fn($fo) => [
                    'nev' => $fo->nev,
                    // saját termékek + összes alkategória termékei együtt
                    'db' => $fo->termekek_count + $fo->alkategoriak->sum('termekek_count'),
                    'alkategoriak' => $fo->alkategoriak->map(fn($al) => [
                        'nev' => $al->nev,
                        'db' => $al->termekek_count,
                    ]),
                ]);

            $categories = $foKategoriak;

            return response()->json([
                'monthlySales' => $monthlySales,
                'monthlyOrders' => $monthlyOrders,
                'categories' => $categories,
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
                'id' => 'ORD-' . $r->id,
                'felhasznalo' => ['nev' => $r->felhasznalo?->felhasz_nev ?? 'Vendég'],
                'termekek_szama' => $r->rendelt_termekek_count,
                'osszeg' => $r->osszeg,
                'statusz' => $r->statusz,
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

    Route::post('/kategoriak', function (Request $request) {
        $validated = $request->validate([
            'nev' => 'required|string|max:255',
            'fo_kategoria_id' => 'nullable|integer|exists:kategoriak,id',
        ]);
        $kat = Kategoriak::create($validated);
        return response()->json($kat, 201);
    });

    Route::post('/szinek', function (Request $request) {
        $validated = $request->validate([
            'nev' => 'required|string|max:100',
            'hex_kod' => 'required|string|max:20',
        ]);
        $szin = Szinek::create($validated);
        return response()->json($szin, 201);
    });

    Route::post('/termekek', function (Request $request) {
        $validated = $request->validate([
            'nev' => 'required|string',
            'kategoria_id' => 'required|integer|exists:kategoriak,id',
            'ar' => 'required|integer|min:0',
            'darab' => 'required|integer|min:0',
            'leiras' => 'nullable|string',
            'fo_kep_id' => 'nullable|integer|exists:kepek,id',
            'szinek' => 'nullable|array',
            'szinek.*' => 'integer|exists:szinek,id',
            'extra_kategoriak' => 'nullable|array',
            'extra_kategoriak.*' => 'integer|exists:kategoriak,id',
            'kepek' => 'nullable|array',
            'kepek.*' => 'integer|exists:kepek,id',
        ]);

        $termek = Termekek::create(\Illuminate\Support\Arr::except(
            $validated,
            ['szinek', 'extra_kategoriak', 'kepek']
        ));

        // Színek csatolása
        if (!empty($validated['szinek'])) {
            foreach ($validated['szinek'] as $szinId) {
                \DB::table('termekszinek')->insert([
                    'termek_id' => $termek->id,
                    'szin_id' => $szinId,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // Extra kategóriák csatolása
        if (!empty($validated['extra_kategoriak'])) {
            foreach ($validated['extra_kategoriak'] as $katId) {
                \DB::table('termekKategoriak')->insertOrIgnore([
                    'termek_id' => $termek->id,
                    'kategoria_id' => $katId,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // ── ÚJ: Képek csatolása a termekKepek pivot táblába ──────
        if (!empty($validated['kepek'])) {
            foreach ($validated['kepek'] as $rendezes => $kepId) {
                \DB::table('termekKepek')->insertOrIgnore([
                    'termek_id' => $termek->id,
                    'kep_id' => $kepId,
                    'rendezes' => $rendezes + 1,  
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        return response()->json(
            $termek->load('TermekKategoria', 'TermekFoKep', 'TermekSzinek', 'TermekKategoriak', 'TermekKepek'),
            201
        );
    });

    Route::put('/termekek/{id}', function (Request $request, $id) {
        $termek = Termekek::findOrFail($id);

        $validated = $request->validate([
            'nev' => 'sometimes|string',
            'kategoria_id' => 'sometimes|integer|exists:kategoriak,id',
            'ar' => 'sometimes|integer|min:0',
            'darab' => 'sometimes|integer|min:0',
            'leiras' => 'nullable|string',
            'fo_kep_id' => 'nullable|integer|exists:kepek,id',
            'szinek' => 'nullable|array',
            'szinek.*' => 'integer|exists:szinek,id',
            'extra_kategoriak' => 'nullable|array',
            'extra_kategoriak.*' => 'integer|exists:kategoriak,id',
            'kepek' => 'nullable|array',
            'kepek.*' => 'integer|exists:kepek,id',
        ]);

        $termek->update(\Illuminate\Support\Arr::except(
            $validated,
            ['szinek', 'extra_kategoriak', 'kepek']
        ));

        // Színek szinkronizálása (teljes csere)
        if (array_key_exists('szinek', $validated)) {
            \DB::table('termekszinek')->where('termek_id', $id)->delete();
            foreach ($validated['szinek'] ?? [] as $szinId) {
                \DB::table('termekszinek')->insert([
                    'termek_id' => $id,
                    'szin_id' => $szinId,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // Extra kategóriák szinkronizálása (teljes csere)
        if (array_key_exists('extra_kategoriak', $validated)) {
            \DB::table('termekKategoriak')->where('termek_id', $id)->delete();
            foreach ($validated['extra_kategoriak'] ?? [] as $katId) {
                \DB::table('termekKategoriak')->insertOrIgnore([
                    'termek_id' => $id,
                    'kategoria_id' => $katId,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // ── ÚJ: Képek szinkronizálása (teljes csere) ─────────────
        // Ha küldtek kepek tömböt, teljesen cseréljük
        if (array_key_exists('kepek', $validated)) {
            \DB::table('termekKepek')->where('termek_id', $id)->delete();
            foreach ($validated['kepek'] ?? [] as $rendezes => $kepId) {
                \DB::table('termekKepek')->insertOrIgnore([
                    'termek_id' => $id,
                    'kep_id' => $kepId,
                    'rendezes' => $rendezes + 1,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        return response()->json(
            $termek->fresh()->load('TermekKategoria', 'TermekFoKep', 'TermekSzinek', 'TermekKategoriak', 'TermekKepek')
        );
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
    //Users
    Route::get('/users', [FelhasznaloController::class, 'index']);
    Route::get('/users/{id}', [FelhasznaloController::class, 'show']);
    Route::post('/users', [FelhasznaloController::class, 'store']);
    Route::put('/users/{id}', [FelhasznaloController::class, 'update']);
    Route::delete('/users/{id}', [FelhasznaloController::class, 'destroy']);

    // Blog CRUD
    Route::get('/blog', [BlogController::class, 'AdminIndex']);
    Route::post('/blog', [BlogController::class, 'store']);
    Route::put('/blog/{id}', [BlogController::class, 'update']);
    Route::delete('/blog/{id}', [BlogController::class, 'destroy']);
});