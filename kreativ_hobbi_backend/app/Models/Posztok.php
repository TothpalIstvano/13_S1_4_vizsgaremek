<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Felhasznalok;
use App\Models\Kepek;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Laravel\Sanctum\HasApiTokens;

class Posztok extends Model
{
    use HasFactory;
    use HasApiTokens;

    protected $table = 'posztok';
    protected $primaryKey = 'id';
    protected $fillable = [
        'cim',
        'kivonat',
        'tartalom',
        'szerzo_id',
        'fo_kep_id',
        'letrehozas_datuma',
        'statusz',
    ];

    protected $casts = [
        'letrehozas_datuma' => 'datetime',
    ];

    public function szerzo()
    {
        return $this->belongsTo(Felhasznalok::class, 'szerzo_id', 'id');
    }

    public function foKep()
    {
        return $this->belongsTo(Kepek::class, 'fo_kep_id', 'id');
    }

    public function cimkek()
    {
        return $this->belongsToMany(Cimkek::class, 'posztCimkek', 'poszt_id', 'cimke_id');
    }

    public function kepek()
    {
        return $this->belongsToMany(Kepek::class, 'posztKepek', 'poszt_id', 'kep_id');
        /*->withPivot('sorrend')
        ->orderBy('sorrend');*/
    }
    public function kommentek()
    {
        return $this->hasMany(Kommentek::class, 'poszt_id')->whereNull('elozetes_komment_id');
    }
}
