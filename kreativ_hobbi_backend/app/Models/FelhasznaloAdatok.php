<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Felhasznalok;
use App\Models\Varosok;

class FelhasznaloAdatok extends Model
{
    use HasFactory;
    protected $table = 'felhasznaloAdatok';

    protected $fillable = [
        'felhasznalo_id',
        'vezeteknev',
        'keresztnev',
        'varos',
        'utca',
        'hazszam',
        'emeletAjto',
        'telefonszam',
        'kartyaszam',
    ];

    public $timestamps = false;    

    public function felhasznalo()
    {
        return $this->belongsTo(Felhasznalok::class, 'felhasznalo_id');
    }
    public function varosAdatok()
    {
        return $this->belongsTo(Varosok::class, 'varos');
    }
}
