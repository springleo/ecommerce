import { useEffect, useState } from "react";

function App() {
  const [products, setProducts] = useState([]);
  const [cart, setCart] = useState([]);

  // Load products + cart
  const loadData = async () => {
    const p = await fetch("/api/products").then((r) => r.json());
    const c = await fetch("/api/cart/user1").then((r) => r.json());
    setProducts(p);
    setCart(c);
  };

  useEffect(() => {
    loadData();
  }, []);

  // Add to cart
  const addToCart = async (product) => {
    await fetch("/api/cart/user1", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(product),
    });

    loadData();
  };

  // Remove from cart
  const removeFromCart = async (index) => {
    await fetch(`/api/cart/user1/${index}`, {
      method: "DELETE",
    });

    loadData();
  };

  // Save for later
  const saveForLater = async (product, index) => {
    await fetch("/api/save/user1", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(product),
    });

    await fetch(`/api/cart/user1/${index}`, {
      method: "DELETE",
    });

    loadData();
  };

  return (
    <div style={styles.page}>
      <h1 style={styles.title}>🛒 Ecommerce Store</h1>

      {/* PRODUCTS */}
      <h2 style={styles.sectionTitle}>Products</h2>
      <div style={styles.grid}>
        {products.map((p) => (
          <div key={p.id} style={styles.card}>
            <h3>{p.name}</h3>
            <p style={styles.price}>₹{p.price}</p>

            <button
              style={styles.button}
              onClick={() => addToCart(p)}
            >
              Add to Cart
            </button>
          </div>
        ))}
      </div>

      {/* CART */}
      <h2 style={styles.sectionTitle}>Cart</h2>
      <div style={styles.cartBox}>
        {cart.length === 0 ? (
          <p>Cart is empty</p>
        ) : (
          cart.map((c, i) => (
            <div key={i} style={styles.cartItemRow}>
              <span>{c.name}</span>

              <div>
                <button
                  style={styles.smallBtn}
                  onClick={() => removeFromCart(i)}
                >
                  Remove
                </button>

                <button
                  style={styles.smallBtnSecondary}
                  onClick={() => saveForLater(c, i)}
                >
                  Save for later
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

// 🎨 Styles
const styles = {
  page: {
    padding: "40px",
    fontFamily: "Segoe UI, sans-serif",
    background: "#0f1117",
    minHeight: "100vh",
    width: "100vw",
    boxSizing: "border-box",
    color: "#e5e7eb",
  },
  title: {
    fontSize: "42px",
    marginBottom: "30px",
  },
  sectionTitle: {
    fontSize: "22px",
    marginBottom: "15px",
  },
  grid: {
    display: "flex",
    gap: "20px",
    flexWrap: "wrap",
  },
  card: {
    background: "#1c1f26",
    padding: "20px",
    borderRadius: "12px",
    width: "220px",
    boxShadow: "0 4px 12px rgba(0,0,0,0.4)",
  },
  price: {
    color: "#60a5fa",
    marginBottom: "10px",
  },
  button: {
    background: "#6366f1",
    border: "none",
    padding: "8px 14px",
    borderRadius: "6px",
    color: "white",
    cursor: "pointer",
  },
  cartBox: {
    background: "#1c1f26",
    padding: "20px",
    borderRadius: "12px",
    width: "360px",
  },
  cartItemRow: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    padding: "8px 0",
    borderBottom: "1px solid #2a2f3a",
  },
  smallBtn: {
    marginRight: "8px",
    background: "#ef4444",
    border: "none",
    padding: "4px 10px",
    borderRadius: "6px",
    color: "white",
    cursor: "pointer",
  },
  smallBtnSecondary: {
    background: "#374151",
    border: "none",
    padding: "4px 10px",
    borderRadius: "6px",
    color: "white",
    cursor: "pointer",
  },
};

export default App;
