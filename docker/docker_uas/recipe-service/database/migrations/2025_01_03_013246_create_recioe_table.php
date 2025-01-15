<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recipe_items', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->date('article_date');
            $table->json('ingredients'); 
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recipe_items');
    }
};
