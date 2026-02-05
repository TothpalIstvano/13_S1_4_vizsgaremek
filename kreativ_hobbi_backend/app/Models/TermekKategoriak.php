<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TermekKategoriak extends Model
{
    use HasFactory;
    protected $table = "termekKategoriak";
    protected $fillable = ["termek_id", "cimke_id"];
    protected $primaryKey = ["termek_id", "cimke_id"];
    public $incrementing = false;

    public function termek()
    {
        return $this->belongsTo(Termekek::class, 'termek_id', 'id');
    }
    public function cimkek()
    {
        return $this->belongsTo(Cimkek::class, 'cimke_id', 'id');
    }
}
