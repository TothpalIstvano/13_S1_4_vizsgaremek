<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Kategoriak extends Model
{
    use HasFactory;
    protected $table = 'kategoriak';
    protected $primaryKey = 'id';
    public $incrementing = true;
    protected $fillable = ['nev', 'fo_kategoria_id'];
    public function foKategoria()
    {
        return $this->belongsTo(Kategoriak::class, 'fo_kategoria_id');
    }
    
    public function alkategoriak()
    {
        return $this->hasMany(Kategoriak::class, 'fo_kategoria_id');
    }

}
