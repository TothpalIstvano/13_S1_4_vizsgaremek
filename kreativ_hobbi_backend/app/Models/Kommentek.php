<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Posztok;
use App\Models\Felhasznalok;
use Laravel\Sanctum\HasApiTokens;

class Kommentek extends Model
{
    use HasFactory;
    protected $table = "kommentek";
    protected $primaryKey = "id";
    protected $fillable = [
        'komment',
        'poszt_id',
        'kommentelo',
        'elozetes_komment_id',
        'letrehozas_datuma',
    ];

    protected $casts = [
        'letrehozas_datuma' => 'datetime'
    ];

    public function elozoKommentek()
    {
        return $this->belongsTo(Kommentek::class, 'elozetes_komment_id', 'id');
    }
    public function gyermekKommentek()
    {
        return $this->hasMany(Kommentek::class, 'elozetes_komment_id', 'id');
    }
    public function kommentIro()
    {
        return $this->belongsTo(Felhasznalok::class, 'kommentelo', 'id');
    }
    public function poszt()
    {
        return $this->belongsTo(Posztok::class, 'poszt_id', 'id');
    }
}
