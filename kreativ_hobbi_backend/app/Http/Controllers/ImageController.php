<?php
namespace App\Http\Controllers;
use App\Models\Kepek;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class ImageController extends Controller
{
    public function upload(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'images.*' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'error' => 'Validation failed',
                    'messages' => $validator->errors()
                ], 422);
            }

            $uploadedImages = [];
            $files = $request->file('images');
            $alts = $request->input('alt', []);
            $descriptions = $request->input('description', []);

            foreach ($files as $index => $file) {
                // Generate unique filename
                $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();

                // Store in public storage
                $path = $file->storeAs('blog', $filename, 'public');

                // Create database record
                $image = Kepek::create([
                    'url_Link' => $path,
                    'alt_Szoveg' => $alts[$index] ?? $file->getClientOriginalName(),
                    'leiras' => $descriptions[$index] ?? 'Blog image uploaded by ' . Auth::user()->felhasz_nev
                ]);

                $uploadedImages[] = [
                    'id' => $image->id,
                    'url' => asset('storage/' . $path), // Use asset() helper for full URL
                    'alt' => $image->alt_Szoveg,
                    'description' => $image->leiras,
                    'path' => $path
                ];
            }

            return response()->json([
                'message' => 'Images uploaded successfully',
                'images' => $uploadedImages
            ], 201);

        } catch (\Exception $e) {
            \Log::error('Image upload error: ' . $e->getMessage());
            return response()->json([
                'error' => 'Failed to upload images',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}