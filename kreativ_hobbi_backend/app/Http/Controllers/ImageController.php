<?php
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use App\Models\Kepek;
use Illuminate\Http\JsonResponse;

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
                // ✅ CORRECT: Use $file (not $request->file('image'))
                $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
                $path = $file->storeAs('blog', $filename, 'public'); // ✅ storeAs()

                // ✅ Generate correct public URL
                $fullUrl = asset('storage/' . $path);

                $image = Kepek::create([
                    'url_Link' => $fullUrl,
                    'alt_Szoveg' => $alts[$index] ?? $file->getClientOriginalName(),
                    'leiras' => $descriptions[$index] ?? 'Blog image uploaded by ' . (Auth::check() ? Auth::user()->felhasz_nev : 'Guest')
                ]);

                $uploadedImages[] = [
                    'id' => $image->id,
                    'url' => $fullUrl,
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
    /*public function upload(Request $request)
    {
        // Skip validation for demo
        $uploadedImages = [];

        // Get base64 images from request
        $base64Images = $request->input('images', []);

        foreach ($base64Images as $index => $base64) {
            // Store base64 directly in database
            $image = Kepek::create([
                'url_Link' => $base64,  // Store base64 string directly
                'alt_Szoveg' => $request->input('alt')[$index] ?? 'Demo image',
                'leiras' => $request->input('description')[$index] ?? 'Demo image description'
            ]);

            $uploadedImages[] = [
                'id' => $image->id,
                'url' => $base64,
                'alt' => $image->alt_Szoveg,
                'description' => $image->leiras
            ];
        }

        return response()->json([
            'message' => 'Images uploaded successfully',
            'images' => $uploadedImages
        ], 201);
    }*/
}