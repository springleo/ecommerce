from fastapi import FastAPI
import redis
import json

app = FastAPI()

r = redis.Redis(host="redis", port=6379, decode_responses=True)

PRODUCTS = [
    {"id": 1, "name": "Laptop", "price": 80000},
    {"id": 2, "name": "Headphones", "price": 3000},
]

@app.get("/products")
def get_products():
    return PRODUCTS

@app.post("/cart/{user_id}")
def add_to_cart(user_id: str, item: dict):
    key = f"cart:{user_id}"
    cart = r.get(key)
    cart_data = json.loads(cart) if cart else []
    cart_data.append(item)
    r.set(key, json.dumps(cart_data))
    return {"status": "added"}

@app.get("/cart/{user_id}")
def view_cart(user_id: str):
    key = f"cart:{user_id}"
    cart = r.get(key)
    return json.loads(cart) if cart else []

@app.delete("/cart/{user_id}/{index}")
def remove_from_cart(user_id: str, index: int):
    key = f"cart:{user_id}"
    cart = r.get(key)
    if not cart:
        return {"status": "empty"}

    cart_data = json.loads(cart)
    if index < len(cart_data):
        cart_data.pop(index)
        r.set(key, json.dumps(cart_data))

    return {"status": "removed"}

@app.post("/save/{user_id}")
def save_for_later(user_id: str, item: dict):
    key = f"saved:{user_id}"
    saved = r.get(key)
    saved_data = json.loads(saved) if saved else []
    saved_data.append(item)
    r.set(key, json.dumps(saved_data))
    return {"status": "saved"}

