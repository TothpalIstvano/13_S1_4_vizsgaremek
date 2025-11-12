<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kep extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'kepek';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'url_Link',
    ];

    /**
     * Get the users associated with the image.
     * An image can be a profile picture for many users.
     */
    public function felhasznalok()
    {
        // 'profilKep_id' is the foreign key in the 'felhasznalok' table
        return $this->hasMany(Felhasznalo::class, 'profilKep_id');
    }
}