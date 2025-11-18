<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kedvencek extends Model
{
    use HasFactory;
    protected $table = "kedvencek";
    protected $fillable = ["felhasznalo_id", "termek_id"];
    protected $primaryKey = ["felhasznalo_id", "termek_id"];
    public $incrementing = false;

    public function termek()
    {
        return $this->belongsTo(Termekek::class);
    }
    public function felhasznalo()
    {
        return $this->belongsTo(Felhasznalok::class);
    }
}
