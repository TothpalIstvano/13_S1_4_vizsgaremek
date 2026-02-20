<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Models\FelhasznaloAdatok;


class Felhasznalok extends Authenticatable implements MustVerifyEmail
{
    use HasFactory, HasApiTokens, Notifiable;


    protected $table = 'felhasznalok';
    protected $authPasswordName = 'jelszo';
    protected $primaryKey = 'id';

    public $incrementing = true;

    public $rememberTokenName = false;
    protected $keyType = 'int';

    protected $fillable = [
        'felhasz_nev',
        'email',
        'jelszo',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'letrehozas_Datuma' => 'datetime',
        'utolso_Belepes' => 'datetime',
    ];

    public function profilKep()
    {
        return $this->belongsTo(Kepek::class, 'profilKep_id', 'id');
    }

    public function setJelszoAttribute($value)
    {
        $this->attributes['jelszo'] = bcrypt($value);
    }

    public function setPasswordAttribute($value)
    {
        $this->attributes['jelszo'] = $value;
    }

    public function getAuthPassword()
    {
        return $this->jelszo;
    }

    public function adatok()
    {
        return $this->hasOne(FelhasznaloAdatok::class, 'felhasznalo_id', 'id');
    }
}