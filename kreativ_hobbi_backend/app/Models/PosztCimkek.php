<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PosztCimkek extends Model
{
    use HasFactory;

    protected $table = 'posztCimkek';
    protected $primaryKey = ['poszt_id', 'cimke_id'];
    public $incrementing = false;
    protected $fillable = [
        'poszt_id',
        'cimke_id',
    ];

    public function poszt()
    {
        return $this->belongsToMany(Posztok::class, 'poszt_id');
    }
    public function cimke()
    {
        return $this->belongsToMany(Cimkek::class, 'cimke_id');
    }

}
