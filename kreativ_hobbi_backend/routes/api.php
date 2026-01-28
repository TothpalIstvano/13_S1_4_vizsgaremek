<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BlogController;
use App\Http\Controllers\KommentController;
use App\Http\Controllers\ImageController;
use App\Models\Posztok;
use App\Models\Termekek;
use App\Models\Cimkek;

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