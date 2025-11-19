<?php 
namespace App\Http\Controllers;
use App\Models\Felhasznalok;


class FelhasznaloController
{
    public function felhasznalo()
    {
        $felhasznalok = Felhasznalok::all();
        return view('teszt', compact('felhasznalok'));
    }   
}