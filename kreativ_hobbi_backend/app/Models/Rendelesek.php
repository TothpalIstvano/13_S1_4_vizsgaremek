<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Rendelesek extends Model
{
    use HasFactory, SoftDeletes;
    protected $table = "rendelesek";
    protected $primaryKey = "id";
    protected $fillable = [
        'felhasznalo_id', 
        'statusz', 
        'fizetes_statusz',
        'osszeg',     
        'szallitasi_nev',
        'szallitasi_email',
        'szallitasi_telefon',
        'szallitasi_utca',
        'szallitasi_hazszam',
        'szallitasi_emeletAjto',
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
