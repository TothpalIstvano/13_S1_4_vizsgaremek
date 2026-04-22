<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Models\Posztok;

class Cimkek extends Model
{
    use HasFactory;
    protected $table = 'cimkek';
    protected $primaryKey = 'id';
    protected $fillable = ['nev'];

    public function posztok()
    {
        return $this->belongsToMany(Posztok::class, 'posztcimkek', 'cimke_id', 'poszt_id');
    }
}
