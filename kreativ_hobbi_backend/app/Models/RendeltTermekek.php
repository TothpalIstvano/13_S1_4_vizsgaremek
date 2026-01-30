<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RendeltTermekek extends Model
{
    use HasFactory;
    protected $table = "rendeltTermekek";
    protected $fillable = [
        "rendelesek_id",
        "termekek_id",
        "mennyiseg",
        "egysegar",
        "szin_id"
    ];
    protected $PrimaryKey = "id";
    
    public function rendeles(){
        return $this->belongsTo(Rendelesek::class, 'rendelesek_id', 'id');
    }
    public function termekek(){
        return $this->belongsTo(Termekek::class, 'termekek_id', 'id');
    }
    public function szin(){
        return $this->belongsTo(Szinek::class, 'szin_id', 'id');
    }
}
