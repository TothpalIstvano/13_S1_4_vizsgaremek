<?php
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use App\Models\Kepek;

class ImageController extends Controller
{
    public function upload(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'images.*' => 'required|max:5120',
            ]);

            if ($validator->fails()) {
                return response()->json(['error' => 'Validation failed', 'messages' => $validator->errors()], 422);
            }

            $allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/avif'];
            $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'avif'];

            foreach ($request->file('images') as $file) {
                $ext = strtolower($file->getClientOriginalExtension());
                $mime = $file->getMimeType();

                if (!in_array($mime, $allowedMimes) && !in_array($ext, $allowedExtensions)) {
                    return response()->json(['error' => 'Invalid file type: ' . $file->getClientOriginalName()], 422);
                }
            }

            $uploadedImages = [];
            $files = $request->file('images');
            $alts = $request->input('alt', []);
            $descriptions = $request->input('description', []);

            foreach ($files as $index => $file) {
                $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
                $file->move(public_path('uploads/blog'), $filename);

                $fullUrl = asset('uploads/blog/' . $filename);

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
                ];
            }

            return response()->json(['message' => 'Images uploaded successfully', 'images' => $uploadedImages], 201);

        } catch (\Exception $e) {
            \Log::error('Image upload error: ' . $e->getMessage());
            return response()->json(['error' => 'Failed to upload images', 'message' => $e->getMessage()], 500);
        }
    }
}