<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TermekKepek extends Model
{
    use HasFactory;
    protected $table = "termekKepek";
    protected $fillable = ["termek_id", "kep_id", "rendezes"];
    protected $primaryKey = ["termek_id", "kep_id"];
    public $incrementing = false;

    public function termek()
    {
        return $this->belongsTo(Termekek::class, 'termek_id', 'id');
    }
    public function kepek()
    {
        return $this->belongsTo(Kepek::class, 'kep_id', 'id');
    }
}
