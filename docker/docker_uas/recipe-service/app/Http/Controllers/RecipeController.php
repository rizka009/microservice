<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;
use App\Models\Recipe;
use App\Helpers\ResponseHelper;

class RecipeController extends Controller
{
    public function index()
    {
        try {
            $recipes = Recipe::orderBy('created_at', 'desc')->get();
            return ResponseHelper::successResponse('Recipes fetched successfully', $recipes);
        } catch (\Throwable $th) {
            Log::error('Error fetching recipes', [
                'message' => $th->getMessage(),
                'file' => $th->getFile(),
                'line' => $th->getLine(),
            ]);

            return ResponseHelper::errorResponse($th->getMessage());
        }
    }

    public function show($id)
    {
        try {
            $recipe = Recipe::find($id);
            if (!$recipe) {
                return ResponseHelper::errorResponse('Recipe not found', 404);
            }

            return ResponseHelper::successResponse('Recipe fetched successfully', $recipe);
        } catch (\Throwable $th) {
            Log::error('Error fetching recipe', [
                'message' => $th->getMessage(),
                'file' => $th->getFile(),
                'line' => $th->getLine(),
            ]);

            return ResponseHelper::errorResponse($th->getMessage());
        }
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string',
            'article_date' => 'required|date',
            'ingredients' => 'required|array',
        ]);

        if ($validator->fails()) {
            return ResponseHelper::errorResponse('Validation failed', 422, $validator->errors());
        }

        try {
            $recipe = Recipe::create($validator->validated());
            return ResponseHelper::successResponse('Recipe created successfully', $recipe, 201);
        } catch (\Throwable $th) {
            Log::error('Error creating recipe', [
                'message' => $th->getMessage(),
                'file' => $th->getFile(),
                'line' => $th->getLine(),
            ]);

            return ResponseHelper::errorResponse($th->getMessage());
        }
    }

    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string',
            'article_date' => 'sometimes|date',
            'ingredients' => 'sometimes|array',
        ]);

        if ($validator->fails()) {
            return ResponseHelper::errorResponse('Validation failed', 422, $validator->errors());
        }

        try {
            $recipe = Recipe::find($id);
            if (!$recipe) {
                return ResponseHelper::errorResponse('Recipe not found', 404);
            }

            $recipe->update($validator->validated());
            return ResponseHelper::successResponse('Recipe updated successfully', $recipe);
        } catch (\Throwable $th) {
            Log::error('Error updating recipe', [
                'message' => $th->getMessage(),
                'file' => $th->getFile(),
                'line' => $th->getLine(),
            ]);

            return ResponseHelper::errorResponse($th->getMessage());
        }
    }

    public function destroy($id)
    {
        try {
            $recipe = Recipe::find($id);
            if (!$recipe) {
                return ResponseHelper::errorResponse('Recipe not found', 404);
            }

            $recipe->delete();
            return ResponseHelper::successResponse('Recipe deleted successfully');
        } catch (\Throwable $th) {
            Log::error('Error deleting recipe', [
                'message' => $th->getMessage(),
                'file' => $th->getFile(),
                'line' => $th->getLine(),
            ]);

            return ResponseHelper::errorResponse($th->getMessage());
        }
    }
}
