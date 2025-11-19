<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable; // Use Authenticatable for user models
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Felhasznalok extends Authenticatable
{
    use HasFactory, Notifiable;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'felhasznalok';

    /**
     * The primary key associated with the table.
     *
     * @var string
     */
    protected $primaryKey = 'id';

    /**
     * Indicates if the model's ID is auto-incrementing.
     *
     * @var bool
     */
    public $incrementing = true;

    /**
     * The data type of the auto-incrementing ID.
     *
     * @var string
     */
    protected $keyType = 'int';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'felhasz_nev',
        'email',
        'jelszo',
        'profilKep_id',
        'statusz',
        'letrehozas_Datuma',
        'utolso_Belepes',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'jelszo',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'letrehozas_Datuma' => 'datetime',
        'utolso_Belepes' => 'datetime',
    ];

    /**
     * Get the profile picture associated with the user.
     */
    public function profilKep()
    {
        // 'profilKep_id' is the foreign key in the 'felhasznalok' table
        // 'id' is the primary key in the 'kepek' table
        return $this->belongsTo(Kepek::class, 'profilKep_id', 'id');
    }

    /**
     * Always hash the password when it is set.
     * This is a mutator that automatically hashes passwords.
     */
    public function setJelszoAttribute($value)
    {
        $this->attributes['jelszo'] = bcrypt($value);
    }
}