<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Felhasznalok;
use App\Models\Varosok;
use Laravel\Sanctum\HasApiTokens;

class FelhasznaloAdatok extends Model
{
    use HasFactory;
    use HasApiTokens;
    protected $table = 'felhasznaloAdatok';
    protected $primaryKey = 'felhasznalo_id';
    protected $guarded = [
        'felhasznalo_id',
        'szerepkor',
    ];

    public $timestamps = false;    

    public function setKartyaszamAttribute($value)
    {
        $this->attributes['kartyaszam'] = bcrypt($value);
    }

    public function felhasznalo()
    {
        return $this->belongsTo(Felhasznalok::class, 'felhasznalo_id', 'id');
    }
    public function varosAdatok()
    {
        return $this->belongsTo(Varosok::class, 'varos', 'id');
    }
}
