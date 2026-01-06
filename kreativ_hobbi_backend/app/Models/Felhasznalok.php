<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable; // Use Authenticatable for user models
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;


class Felhasznalok extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;


    protected $table = 'felhasznalok';
    protected $primaryKey = 'id';

    public $incrementing = true;

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

    public function getAuthPassword()
    {
        return $this->jelszo;
    }
}