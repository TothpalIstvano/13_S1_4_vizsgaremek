<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Felhasznalok;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rules;

class RegisteredUserController extends Controller
{
    /**
     * Handle an incoming registration request.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request): Response
    {
        $request->validate([
            'felhasz_nev' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:'.Felhasznalok::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        $user = Felhasznalok::create([
            'felhasz_nev' => $request->felhasz_nev,
            'email' => $request->email,
            'jelszo' => $request->password,
        ]);

        event(new Registered($user));

        Auth::login($user);

        return response()->noContent();
    }
}
