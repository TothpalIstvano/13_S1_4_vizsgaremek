<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Termekek extends Model
{
    use HasFactory;
    protected $table = "termekek";
    protected $PrimaryKey = "id";
    public $timestamps = true;
    protected $fillable = ['nev', 'leiras', 'ar', 'darab', 'meter', 'kategoria_id', 'fo_kep_id'];

    public function kategoria()
    {
        return $this->belongsTo(Kategoriak::class);
    }
    public function kepek()
    {
        return $this->belongsTo(Kepek::class);
    }
}
