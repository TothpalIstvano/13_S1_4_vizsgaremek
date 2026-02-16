<?php
namespace App\Http\Controllers;
use App\Models\Felhasznalok;
use App\Models\FelhasznaloAdatok;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;


class FelhasznaloController
{
    public function updateProfile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'vezeteknev' => 'required|string|max:100',
            'keresztnev' => 'required|string|max:100',
            'telefonszam' => 'nullable|string|max:20',
            'utca' => 'nullable|string|max:255',
            'hazszam' => 'nullable|integer',
            'emeletAjto' => 'nullable|string|max:10',
            'varos' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $request->only([
            'vezeteknev',
            'keresztnev',
            'telefonszam',
            'utca',
            'hazszam',
            'emeletAjto',
            'varos'
        ]);

        // Handle empty values correctly
        $data['telefonszam'] = $request->filled('telefonszam') ? $request->telefonszam : '';
        $data['utca'] = $request->filled('utca') ? $request->utca : '';
        $data['emeletAjto'] = $request->filled('emeletAjto') ? $request->emeletAjto : '';
        $data['hazszam'] = $request->filled('hazszam') ? (int) $request->hazszam : 0;   // integer, 0 if empty
        $data['varos'] = $request->filled('varos') ? (int) $request->varos : null; // nullable foreign key

        $userData = FelhasznaloAdatok::updateOrCreate(
            ['felhasznalo_id' => $request->user()->id],
            $data
        );

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $request->user()->load('profilKep', 'adatok')
        ]);
    }

    public function updateProfilePicture(Request $request)
    {
        $request->validate([
            'profilKep_id' => 'required|integer|exists:kepek,id'
        ]);

        $user = $request->user();
        $user->profilKep_id = $request->profilKep_id;
        $user->save();

        return response()->json([
            'message' => 'Profile picture updated',
            'user' => $user->load('profilKep', 'adatok')
        ]);
    }
}