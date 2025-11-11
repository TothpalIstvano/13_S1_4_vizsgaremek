<?php 
namespace App\Http\Controllers;
use App\Models\Felhasznalok;

class FelhasznalokController
{
    public function felhasznalok()
    {
        $felhasznalok = Felhasznalok::all();

        return view('teszt', compact('felhasznalok'));
    }
    public function felhasznalokCreate($felhasznalo)
    {
        $ujFelhasznalo = new Felhasznalok();
        $ujFelhasznalo->nev = $felhasznalo;
        $ujFelhasznalo->email = $felhasznalo . '@example.com';
        $ujFelhasznalo->jelszo = bcrypt('defaultpassword');
        $ujFelhasznalo->statusz = 'aktív';
        $ujFelhasznalo->save();
        
        return "Új felhasználó létrehozva: " . $felhasznalo;
    }
}