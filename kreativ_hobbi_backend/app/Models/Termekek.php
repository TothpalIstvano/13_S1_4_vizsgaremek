<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Termekek extends Model
{
    use HasFactory;
    protected $table = "termekek";
    protected $PrimaryKey = "id";
    public $timestamps = true;
    protected $fillable = ['nev', 'leiras', 'ar', 'darab', 'meter', 'kategoria_id', 'fo_kep_id'];

    public function TermekKategoria()
    {
        return $this->belongsTo(Kategoriak::class, 'kategoria_id', 'id');
    }
    public function TermekFoKep()
    {
        return $this->belongsTo(Kepek::class, 'fo_kep_id', 'id');
    }

    public function TermekKepek()
    {
        return $this->belongsToMany(Kepek::class,'termekKepek', 'termek_id', 'id');
    }

    public function TermekSzinek()
    {
        return $this->belongsToMany(Szinek::class,'termekSzinek', 'termek_id', 'szin_id');
    }

    public function TermekCimkek()
    {
        return $this->belongsToMany(Cimkek::class, 'termekCimkek', 'termek_id', 'cimke_id');
    }
}