<?php
    namespace App\Models;
    use Illuminate\Database\Eloquent\Model;
    class Felhasznalok extends Model
    {
        protected $table = "felhasznalok";
        protected $primaryKey = 'id';
        public $incrementing = true;
        protected $keyType = 'integer';
        public $timestamps = true;
        const CREATED_AT = 'created_at';
        const UPDATED_AT = 'updated_at';

    }
?>