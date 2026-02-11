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
                $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();

                $path = $file->storeAs('blog', $filename, 'public');

                $fullUrl = asset('storage/' . $path);
                //vagy hátha talán: $fullUrl = url('images/blog/' . basename($path));

                $image = Kepek::create([
                    'url_Link' => $fullUrl,
                    'alt_Szoveg' => $alts[$index] ?? $file->getClientOriginalName(),
                    'leiras' => $descriptions[$index] ?? 'Blog image uploaded by ' . Auth::user()->felhasz_nev
                ]);
                /* ez is hátha megoldja
                $filePath = Storage::disk('public')->path($path);
                chmod($filePath, 0644);*/

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
}