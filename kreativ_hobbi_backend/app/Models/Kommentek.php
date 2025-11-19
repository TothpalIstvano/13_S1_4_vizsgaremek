<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class Kommentek extends Model
{
    use HasFactory,HasApiTokens;
    protected $table = "kommentek";
    protected $primarykey = "id";
    protected $fillable = [
        'komment',
        'poszt_id',
        'kommentelo',
        'elozetes_komment_id'
    ];
    public function elozoKommentek(){
        return $this->belongsTo(Kommentek::class);
    }
    public function kommentIro(){
        return $this->belongsTo(Felhasznalok::class);
    }
    public function poszt(){
        return $this->belongsTo(Posztok::class);
    }
}
