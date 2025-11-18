<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Posztok;
use App\Models\Kepek;

class PosztKepek extends Model
{
    use HasFactory;
    protected $table = 'posztKepek';
    protected $primaryKey = ['poszt_id', 'kep_id'];
    public $incrementing = false;
    protected $fillable = [
        'poszt_id',
        'kep_id',
    ];

    public function poszt()
    {
        return $this->belongsTo(Posztok::class, 'poszt_id');
    }

    public function kep()
    {
        return $this->belongsTo(Kepek::class, 'kep_id');
    }
}
