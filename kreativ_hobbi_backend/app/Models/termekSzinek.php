<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class termekSzinek extends Model
{
    use HasFactory;
    protected $table = "termekSzinek";
    protected $PrimaryKey = ["termek_id", "szin_id"];
    public $incrementing = false;
    protected $fillables = ["termek_id", "szin_id"];

    public function termek()
    {
        return $this->belongsTo(Termekek::class, 'termek_id', 'id');
    }
    public function termekSzinek()
    {
        return $this->belongsToMany(Szinek::class, 'termekSzinek', 'termek_id', 'szin_id');
    }
}
