<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class Rendelesek extends Model
{
    use HasFactory;
    protected $table = "rendelesek";
    protected $PrimaryKey = "id";
    protected $fillable = [
        'felhasznalo_id', 
        'statusz', 
        'fizetes_statusz',
        'osszeg',     
        'szallitasi_nev',
        'szallitasi_email',
        'szallitasi_telefon',
        'szallitasi_cim',
        'szallitasi_varos_nev',
        'szallitasi_varos_id',
        'rendeles_datuma', 
    ];


    


    public function felhasznalo()
    {
        return $this->belongsTo(Felhasznalok::class, 'felhasznalo_id', 'id');
    }

    public function rendeltTermekek()
    {
        return $this->hasMany(RendeltTermekek::class, 'rendeles_id', 'id');
    }
}
