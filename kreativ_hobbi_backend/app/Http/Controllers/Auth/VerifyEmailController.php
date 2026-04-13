<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Auth\Events\Verified;
use Illuminate\Http\Request;
use App\Models\Felhasznalok;

class VerifyEmailController extends Controller
{
    public function __invoke(Request $request, $id, $hash)
    {
        $user = Felhasznalok::findOrFail($id);

        // Signature ellenőrzés (lejárat is benne van)
        if (! $request->hasValidSignature()) {
            return response()->json(['message' => 'Érvénytelen vagy lejárt link'], 403);
        }

        if (! hash_equals((string) $hash, sha1($user->getEmailForVerification()))) {
            return response()->json(['message' => 'Érvénytelen link'], 403);
        }

        if ($user->hasVerifiedEmail()) {
            return redirect(config('app.frontend_url') . '/email-already-verified');
        }

        $user->markEmailAsVerified();
        event(new Verified($user));

        return redirect(config('app.frontend_url') . '/email-verified');
    }
}