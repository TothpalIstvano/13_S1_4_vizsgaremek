<?php

namespace App\Http\Controllers;

use App\Models\Posztok;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class PosztController extends Controller
{
    public function store(Request $request)
    {
        if (!Auth::check()) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'kivonat' => 'nullable|string|max:255',
            'status' => 'required|in:piszkozat,közzétett',
            'tags' => 'nullable|array',
            'images' => 'nullable|array',
            'images.*.id' => 'nullable|integer|exists:kepek,id',
        ]);

        $user = Auth::user();

        $post = new Posztok();
        $post->cim = $validated['title'];
        $post->tartalom = $validated['content'];
        $post->kivonat = $validated['kivonat'] ?? substr(strip_tags($validated['content']), 0, 200);
        $post->szerzo_id = $user->id;
        $post->statusz = $validated['status'];
        $post->save();

        if (!empty($validated['tags'])) {
            $post->cimkek()->attach($validated['tags']);
        }

        if (!empty($validated['images'])) {
            $imageIds = array_column($validated['images'], 'id');
            $post->kepek()->attach($imageIds);
            if (!empty($imageIds)) {
                $post->fo_kep_id = $imageIds[0];
                $post->save();
            }
        }

        return response()->json([
            'message' => 'Post created successfully',
            'post' => $post->load('cimkek')
        ], 201);
    }

    public function edit($id)
    {
        $post = Posztok::with(['cimkek', 'kepek'])->findOrFail($id);

        if ($post->szerzo_id !== Auth::id()) {
            return response()->json(['error' => 'Forbidden'], 403);
        }

        return response()->json($post);
    }

    public function update(Request $request, $id)
    {
        if (!Auth::check()) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $post = Posztok::findOrFail($id);

        if ($post->szerzo_id !== Auth::id()) {
            return response()->json(['error' => 'Forbidden'], 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'kivonat' => 'nullable|string|max:255',
            'status' => 'required|in:piszkozat,közzétett',
            'tags' => 'nullable|array',
            'images' => 'nullable|array',
            'images.*.id' => 'nullable|integer|exists:kepek,id',
        ]);

        $post->cim = $validated['title'];
        $post->tartalom = $validated['content'];
        $post->kivonat = $validated['kivonat'] ?? substr(strip_tags($validated['content']), 0, 200);
        $post->statusz = $validated['status'];
        $post->save();

        if (isset($validated['tags'])) {
            $post->cimkek()->sync($validated['tags']);
        } else {
            $post->cimkek()->detach();
        }

        if (isset($validated['images'])) {
            $imageIds = array_column($validated['images'], 'id');
            $post->kepek()->sync($imageIds);
            $post->fo_kep_id = !empty($imageIds) ? $imageIds[0] : null;
        } else {
            $post->kepek()->detach();
            $post->fo_kep_id = null;
        }
        $post->save();

        return response()->json(['message' => 'Post updated successfully']);
    }
}