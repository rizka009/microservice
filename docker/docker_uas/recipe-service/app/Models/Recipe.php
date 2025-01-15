<?php 

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Recipe extends Model
{
    protected $table = 'recipe_items'; 

    protected $fillable = [
        'name',          
        'article_date', 
        'ingredients',  
    ];

    protected $casts = [
        'ingredients' => 'array', 
    ];
}
