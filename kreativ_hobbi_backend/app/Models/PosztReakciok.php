<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class PosztReakciok extends Model
{
    use HasFactory;
    protected $table = "posztReakciok";
    protected $fillable = ["poszt_id", "felhasznalo_id", "reakcio"];

    protected $PrimaryKey = ["poszt_id", "felhasznalo_id"];
    public $incrementing = false;
    public function poszt(){
        return $this->belongsTo(Posztok::class,"poszt_id", "id");
    }
    public function felhasznalo(){
        return $this->belongsTo(Felhasznalok::class,"felhasznalo_id", "id");
    }
}
