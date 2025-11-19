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
    protected $fillable = ['felhasznalo_id', 'statusz', 'osszeg', 'rendeles_datuma'];

    public function felhasznalo()
    {
        return $this->belongsTo(Felhasznalok::class, 'felhasznalo_id');
    }
}
