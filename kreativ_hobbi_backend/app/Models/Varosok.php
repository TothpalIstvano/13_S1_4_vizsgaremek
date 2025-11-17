<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;


class Varosok extends Model
{
    use HasFactory;

    protected $table = 'varosok';
    public $timestamps = false;
    protected $primaryKey = 'id';
    protected $fillable = [
        'varos_nev',
    ];

}
