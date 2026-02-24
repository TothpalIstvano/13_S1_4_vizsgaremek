<?php
namespace App\Http\Controllers;
use App\Models\Felhasznalok;
use App\Models\FelhasznaloAdatok;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

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
    public function index()
    {
        // Load users with their profile picture and details
        $users = Felhasznalok::with('profilKep:id,url_Link,alt_szoveg', 'adatok')
            ->get()
            ->map(function ($user) {
                // Format data to match the Vue component structure
                return [
                    'id' => $user->id,
                    'name' => $user->felhasz_nev, // Maps to 'Név' in table
                    'email' => $user->email,
                    'role' => $user->adatok->szerepkor ?? 'sima', // Maps to 'Szerepkör'
                    'aktiv' => (bool) $user->statusz, 
                    'profileImage' => $user->profilKep ? $user->profilKep->url_Link :'localhost:8000/storage/profilkepek/default.jpg',
                    'created_at' => $user->created_at,
                    'utolso_Belepes' => $user->utolso_Belepes,
                ];
            });

        return response()->json($users);
    }

    /**
     * Store a newly created user in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|unique:felhasznalok,email',
            'password' => 'required|string|min:6',
            'felhasz_nev' => 'required|string|max:100|unique:felhasznalok,felhasz_nev',
            'szerepkor' => 'required|in:admin,moderator,sima,felfuggesztett',
            'aktiv' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            \DB::beginTransaction();

            // Create User
            $user = Felhasznalok::create([
                'email' => $request->email,
                'jelszo' => Hash::make($request->password), // Assuming 'jelszo' is the password column
                'felhasz_nev' => $request->felhasz_nev,
                'aktiv' => $request-> has('aktiv') ? 1 : 0,
            ]);

            // Create User Details (FelhasznaloAdatok)
            FelhasznaloAdatok::create([
                'felhasznalo_id' => $user->id,
                'szerepkor' => $request->szerepkor,
            ]);

            \DB::commit();

            // Return the same format as index for the frontend
            return response()->json([
                'id' => $user->id,
                'name' => $user->felhasz_nev,
                'email' => $user->email,
                'role' => $request->szerepkor,
                'aktiv' => (bool) $user->aktiv,
                'profileImage' => null
            ], 201);

        } catch (\Exception $e) {
            \DB::rollBack();
            return response()->json(['error' => 'Hiba történt a létrehozás során: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Display the specified user.
     */
    public function show($id)
    {
        $user = Felhasznalok::with('profilKep', 'adatok')->find($id);

        if (!$user) {
            return response()->json(['error' => 'Felhasználó nem található'], 404);
        }

        return response()->json([
            'id' => $user->id,
            'name' => $user->felhasz_nev,
            'email' => $user->email,
            'role' => $user->adatok->szerepkor ?? 'user',
            'aktiv' => (bool) $user->aktiv,
            'profileImage' => $user->profilKep ? $user->profilKep->url_Link : null,
            'details' => $user->adatok
        ]);
    }

    /**
     * Update the specified user in storage.
     */

    public function update(Request $request, $id)
    {
        $user = Felhasznalok::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'email' => ['sometimes', 'email', Rule::unique('felhasznalok')->ignore($user->id)],
            'felhasz_nev' => ['sometimes', 'string', 'max:100', Rule::unique('felhasznalok')->ignore($user->id)],
            'szerepkor' => 'required|in:admin,moderator,sima,felfuggesztett',
            'aktiv' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            \DB::beginTransaction();

            // Update Felhasznalok
            $userData = [
                'email' => $request->email ?? $user->email,
                'felhasz_nev' => $request->felhasz_nev ?? $user->felhasz_nev,
                'aktiv' => $request->has('aktiv') ? 1 : 0,
            ];

            // Handle Password Reset (NOT allowed in update via this admin dashboard usually, 
            // but if you wanted to allow it, you would check $request->filled('password') here.
            // Based on your request, we skip password updates entirely for existing users.

            // Handle Profile Picture Reset
            if ($request->has('reset_profile_pic') && $request->reset_profile_pic) {
                $userData['profilKep_id'] = null; // Set to null so frontend uses default
            }

            $user->update($userData);

            // Update FelhasznaloAdatok
            FelhasznaloAdatok::updateOrCreate(
                ['felhasznalo_id' => $user->id],
                [
                    'szerepkor' => $request->szerepkor ?? $user->adatok->szerepkor ?? 'sima',
                ]
            );

            \DB::commit();

            $user->load('profilKep', 'adatok');

            return response()->json([
                'id' => $user->id,
                'name' => $user->felhasz_nev,
                'email' => $user->email,
                'role' => $user->adatok->szerepkor,
                'aktiv' => (bool) $user->statusz,
                'profileImage' => $user->profilKep ? $user->profilKep->url_Link : null
            ]);

        } catch (\Exception $e) {
            \DB::rollBack();
            return response()->json(['error' => 'Hiba történt a frissítés során: ' . $e->getMessage()], 500);
        }
    }

        /**
     * Remove the specified user from storage.
     */
    public function destroy($id)
    {
        $user = Felhasznalok::find($id);

        if (!$user) {
            return response()->json(['error' => 'Felhasználó nem található'], 404);
        }

        // Prevent deleting yourself
        if (auth()->check() && auth()->id() == $id) {
            return response()->json(['error' => 'Nem törölheted a saját fiókodat'], 403);
        }

        try {
            \DB::beginTransaction();

            // --- CHECK: Only delete if ALL orders are completed ---
            $hasActiveOrders = \DB::table('rendelesek')
                ->where('felhasznalo_id', $id)
                ->where('statusz', '!=', 'teljesítve') 
                ->exists();

            if ($hasActiveOrders) {
                \DB::rollBack();
                return response()->json([
                    'error' => 'Nem törölheted ezt a felhasználót, mert vannak aktív vagy függőben lévő rendelései!'
                ], 403);
            }

            // --- DELETE: Orders ---
            // Note: We are NOT deleting 'rendelt_termekek' because that table does not exist in your DB.
            // Since we can only delete completed orders here, this is safe.
            \DB::table('rendelesek')->where('felhasznalo_id', $id)->delete();

            // --- DELETE: Posts ---
            \DB::table('posztok')->where('szerzo_id', $id)->delete();

            // --- DELETE: Favorites ---
            \DB::table('kedvencek')->where('felhasznalo_id', $id)->delete();

            // --- DELETE: Comments ---
            // REMOVED: We are skipping comments because 'felhasznalo_id' column is missing.
            // If you want to delete comments later, check if the column is named 'user_id' instead.

            // --- DELETE: User Details ---
            // REMOVED: Table 'felhasznalo_adatok' does not exist.

            // --- FINAL: Delete the User ---
            $user->delete();

            \DB::commit();

            return response()->json(['message' => 'Felhasználó sikeresen törölve']);
        } catch (\Exception $e) {
            \DB::rollBack();
            \Log::error('User deletion failed: ' . $e->getMessage());
            return response()->json(['error' => 'Hiba történt a törlés során: ' . $e->getMessage()], 500);
        }
    }
}