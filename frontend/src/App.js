import React, { useEffect, useState } from "react";

function App() {
  const [products, setProducts] = useState([]);
  const [cart, setCart] = useState([]);

  useEffect(() => {
    fetch("http://backend:8000/products")
      .then(res => res.json())
      .then(data => setProducts(data));

    fetch("http://backend:8000/cart/user1")
      .then(res => res.json())
      .then(data => setCart(data));
  }, []);

  return (
    <div>
      <h1>Ecommerce Store</h1>

      <h2>Products</h2>
      {products.map(p => (
        <div key={p.id}>
          {p.name} - ₹{p.price}
        </div>
      ))}

      <h2>Cart</h2>
      {cart.map((c,i) => (
        <div key={i}>
          {c.name}
        </div>
      ))}
    </div>
  );
}

export default App;
