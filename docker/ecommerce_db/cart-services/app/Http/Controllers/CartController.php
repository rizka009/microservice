<?php

namespace App\Http\Controllers;

use App\Helpers\ResponseHelper;
use App\Models\CartItems;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class CartController extends Controller
{
    private $client;
    public function __construct()
    {
        $appEnv = env('APP_ENV', 'local');
        $baseUri = $appEnv == 'local' ? 'http://localhost:3000' : 'http://product-services:3000';
        $this->client = new \GuzzleHttp\Client(['base_uri' => $baseUri]);
    }

    public function getProduct($productId = null)
    {
        try {
            $url = $productId ? "products/{$productId}" : "/products";
            Log::info(["url" => $url]);
            $response = $this->client->request("GET", $url);
            $responseData = json_decode($response->getBody()->getContents(), true);

            if ($response->getStatusCode() === 200 && isset($responseData['data'])) {
                return $responseData['data'];
            }

            return null;
        } catch (\Throwable $th) {
            Log::error([
                'message' => $th->getMessage(),
                'file' => $th->getFile(),
                'line' => $th->getLine(),
            ]);

            return null;
        }
    }


    public function index()
    {
        try {
            $data = CartItems::orderBy('created_at', 'desc')->get();
            return ResponseHelper::successResponse('Cart Items fetched successfully', $data);
        } catch (\Throwable $th) {
            Log::error([
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
            $data = CartItems::find($id);
            if (!$data)return ResponseHelper::errorResponse('Cart item not found', 404);

            return ResponseHelper::successResponse('Cart item fetched successfully', $data);
        } catch (\Throwable $th) {
            Log::error([
                'message' => $th->getMessage(),
                'file' => $th->getFile(),
                'line' => $th->getLine()
            ]);

            return ResponseHelper::errorResponse($th->getMessage());
        }
    }

    public function store(Request $request)
    {
        $validate = $this->validate($request, [
            'product_id' => 'required|integer',
            'quantity'   => 'required|integer',
        ]);

        try {
            $product = $this->getProduct($validate['product_id']);

            if (!$product) return ResponseHelper::errorResponse('Product not found', 404);


            $data = CartItems::create([
                'product_id' => $validate['product_id'],
                'name'       => $product['name'],
                'quantity'   => $validate['quantity'],
                'price'      => $product['price'] * $validate['quantity'],
            ]);

            if (!$data) {
                return ResponseHelper::errorResponse('Failed to create cart item', 500);
            }

            return ResponseHelper::successResponse('Cart item created successfully', $data);
        } catch (\Throwable $th) {
            Log::error([
                'message' => $th->getMessage(),
                'file'    => $th->getFile(),
                'line'    => $th->getLine(),
            ]);

            return ResponseHelper::errorResponse($th->getMessage());
        }
    }


    public function update(Request $request, $id)
    {
        $validate = $this->validate($request, [
            'quantity' => 'required|integer',
        ]);

        try {
            $data = CartItems::find($id);
            if (!$data) {
                return ResponseHelper::errorResponse('Cart item not found', 404);
            }

            $product = $this->getProduct($data->product_id);

            if (!$product || !is_array($product) || !isset($product['price'])) {
                return ResponseHelper::errorResponse('Product not found or price unavailable', 404);
            }

            $originalPrice = $product['price'];

            $data->quantity = $validate['quantity'];
            $data->price = $originalPrice * $validate['quantity'];
            $data->save();

            return ResponseHelper::successResponse('Cart item updated successfully', $data);
        } catch (\Throwable $th) {
            Log::error([
                'message' => $th->getMessage(),
                'file'    => $th->getFile(),
                'line'    => $th->getLine(),
            ]);

            return ResponseHelper::errorResponse($th->getMessage());
        }
    }


    public function destroy($id)
    {
        try {
            $data = CartItems::find($id);
            if (!$data)return ResponseHelper::errorResponse('Cart item not found', 404);

            $data->delete();

            return ResponseHelper::successResponse('Cart item deleted successfully');
        } catch (\Throwable $th) {
            Log::error([
                'message' => $th->getMessage(),
                'file' => $th->getFile(),
                'line' => $th->getLine()
            ]);

            return ResponseHelper::errorResponse($th->getMessage());
        }
    }

}
