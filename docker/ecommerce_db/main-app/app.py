from flask import Flask, jsonify, render_template, request
from flask_cors import CORS
import requests
from functools import lru_cache
import os

app = Flask(__name__)

CORS(app)

#Deteksi Environment
product_service_host = "localhost" if os.getenv("HOSTNAME") is None else "product-services"
cart_service_host = "localhost" if os.getenv("HOSTNAME") is None else "cart-service"
review_service_host = "localhost" if os.getenv("HOSTNAME") is None else "review-service"

#Fungsi get products
@lru_cache(maxsize=128)
def get_product_data(product_id):
    try:
        response = requests.get(f'http://{product_service_host}:3000/products/{product_id}')
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching product data: {e}")
        return {"error": "Failed to fetch product data"}
    
# get cart data 
# def get_cart_data(product_id):
#     try:
#         response = requests.get(f'http://{cart_service_host}:3002/cart/{product_id}')
#         response.raise_for_status()
#         data = response.json()

#         if 'data' in data:
#             cart_items = data['data'] 
#             total_quantity = 0

#             if isinstance(cart_items, dict) and 'product_id' in cart_items:
#                 # if cart_items['product_id'] == product_id:
#                     total_quantity = cart_items.get('quantity', 0)

#             # print(f"Total quantity for product_id {product_id}: {total_quantity}")
#                     return total_quantity
#         else:
#             print("Invalid data format:", data)
#             return 0  
#     except requests.exceptions.RequestException as e:
#         print(f"Error fetching cart data: {e}")
#         return {"error": "Failed to get cart data"}
    
def get_cart_data(product_id):
    try:
        response = requests.get(f'http://{cart_service_host}:3002/cart/{product_id}')
        response.raise_for_status()
        data = response.json()
        
        if 'data' in data:
            cart_items = data['data']
            if isinstance(cart_items, dict) and 'product_id' in cart_items:
                return cart_items.get('quantity', 0)
        return 0
    
    except requests.exceptions.RequestException as e:
        print(f"Error Fetching cart data: {e}")
        return 0

#get review data    
def get_review_data(product_id):
    try:
        response = requests.get(f'http://{review_service_host}:3003/products/{product_id}/reviews')
        response.raise_for_status()
        data = response.json()

        return data.get('data', {"reviews": [], "product": {}})
    except requests.exceptions.RequestException as e:
        print(f"Error fetching review data: {e}")
        return {"error": "Failed to fetch review data"}
    
    
@app.route('/product/<int:product_id>')
def get_product_info(product_id):
    #retrieve data from each service
    product = get_product_data(product_id)
    cart = get_cart_data(product_id)
    review = get_review_data(product_id)
    
    # return jsonify(cart)

    #marge all data into one project
    combined_response = {
        "product": product if "error" not in product else None,
        "cart": cart,
        "reviews": review.get("reviews", []) if "error" not in review else []
    }

    #returning format json if the parameter ?format=json added
    if request.args.get('format') == 'json':
        return jsonify({
            "data": combined_response,
            "message": "Product data fetched successfully" if product else "Failed to fetch product data"
        })

    return render_template('product.html', **combined_response)

if __name__ == '__main__':
    app.run(debug=True, port=3006, host="0.0.0.0")