<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TermekKategoriak extends Model
{
    use HasFactory;
    protected $table = "termekKategoriak";
    protected $fillable = ["termek_id", "kategoria_id"];
    protected $primaryKey = ["termek_id", "kategoria_id"];
    public $incrementing = false;

    public function termek()
    {
        return $this->belongsTo(Termekek::class, 'termek_id', 'id');
    }
    public function cimkek()
    {
        return $this->belongsTo(Cimkek::class, 'kategoria_id', 'id');
    }
}
