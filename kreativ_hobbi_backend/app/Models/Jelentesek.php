<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Jelentesek extends Model
{
    protected $table = 'jelentesek';

    protected $fillable = [
        'bejelento_id',
        'tipus',
        'poszt_id',
        'komment_id',
        'ok',
        'leiras',
        'statusz',
        'admin_megjegyzes',
        'kezelo_admin_id',
        'kezeles_datuma',
    ];

    protected $casts = [
        'kezeles_datuma' => 'datetime',
    ];

    public function bejelento(): BelongsTo
    {
        return $this->belongsTo(Felhasznalok::class, 'bejelento_id');
    }

    public function poszt(): BelongsTo
    {
        return $this->belongsTo(Posztok::class, 'poszt_id');
    }

    public function komment(): BelongsTo
    {
        return $this->belongsTo(Kommentek::class, 'komment_id');
    }

    public function kezeloAdmin(): BelongsTo
    {
        return $this->belongsTo(Felhasznalok::class, 'kezelo_admin_id');
    }

    public function scopeFuggoben($query)
    {
        return $query->where('statusz', 'fuggoben');
    }

    public function scopePosztok($query)
    {
        return $query->where('tipus', 'post');
    }

    public function scopeKommentek($query)
    {
        return $query->where('tipus', 'comment');
    }
}