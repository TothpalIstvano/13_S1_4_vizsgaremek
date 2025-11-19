<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Felhasznalok;
use App\Models\Kepek;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Laravel\Sanctum\HasApiTokens;

class Posztok extends Model
{
    use HasFactory, HasApiTokens;
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

    public function szerzo()
    {
        return $this->belongsTo(Felhasznalok::class, 'szerzo_id');
    }
    public function foKep()
    {
        return $this->belongsToMany(Kepek::class, 'fo_kep_id');
    }
}
