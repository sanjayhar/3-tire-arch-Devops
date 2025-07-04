#!/bin/bash

# Variables
REPO_NAME="healthy-breakfast-shop"
GITHUB_USER="YOUR_GITHUB_USERNAME"
RENDER_SERVICE_NAME="breakfast-shop"
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"
DB_DIR="database"

# 1. Create repo directories
mkdir -p $REPO_NAME/$FRONTEND_DIR
mkdir -p $REPO_NAME/$BACKEND_DIR
mkdir -p $REPO_NAME/$DB_DIR

cd $REPO_NAME

# 2. Create sample frontend (React)
cat > $FRONTEND_DIR/package.json <<EOF
{
  "name": "breakfast-frontend",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "scripts": {
    "start": "npx serve -s build"
  }
}
EOF

cat > $FRONTEND_DIR/App.js <<EOF
import React from "react";
const menu = [
  { name: "Avocado Toast", price: "\$6" },
  { name: "Greek Yogurt Parfait", price: "\$5" },
  { name: "Oatmeal Bowl", price: "\$4" },
  { name: "Smoothie Bowl", price: "\$7" },
  { name: "Egg White Omelette", price: "\$6" },
  { name: "Fruit Salad", price: "\$3" }
];
export default function App() {
  return (
    <div style={{fontFamily: "sans-serif", background: "#f8f9fa", minHeight: "100vh"}}>
      <header style={{background: "#ffb347", padding:20, textAlign:"center", fontSize:32, color:"#fff", borderRadius: 10}}>
        🥑 Healthy Breakfast Shop 🥣
      </header>
      <main style={{margin: "50px auto", maxWidth: 400, boxShadow: "0 2px 8px #ddd", borderRadius: 12, background: "#fff", padding: 32}}>
        <h2 style={{color: "#ffa500"}}>Menu</h2>
        <ul style={{listStyle:"none", padding:0}}>
          {menu.map((item, idx) => (
            <li key={idx} style={{margin:"18px 0", fontSize:20, display:"flex", justifyContent:"space-between"}}>
              {item.name} <span>{item.price}</span>
            </li>
          ))}
        </ul>
      </main>
    </div>
  );
}
EOF

cat > $FRONTEND_DIR/index.js <<EOF
import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
createRoot(document.getElementById("root")).render(<App />);
EOF

cat > $FRONTEND_DIR/public/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Healthy Breakfast Shop</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# 3. Create sample backend (Node.js/Express)
cat > $BACKEND_DIR/package.json <<EOF
{
  "name": "breakfast-backend",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.1",
    "cors": "^2.8.5"
  }
}
EOF

cat > $BACKEND_DIR/server.js <<EOF
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const app = express();
const port = process.env.PORT || 8080;
app.use(cors());
app.use(express.json());
// Connect to PostgreSQL (use Render or RDS endpoint in production)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});
app.get("/api/menu", async (req, res) => {
  try {
    const { rows } = await pool.query("SELECT name, price FROM menu");
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});
app.listen(port, () => console.log(\`Backend running at http://localhost:\${port}\`));
EOF

# 4. Create sample database schema (PostgreSQL)
cat > $DB_DIR/schema.sql <<EOF
CREATE TABLE IF NOT EXISTS menu (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price VARCHAR(10) NOT NULL
);
INSERT INTO menu (name, price) VALUES
('Avocado Toast', '\$6'),
('Greek Yogurt Parfait', '\$5'),
('Oatmeal Bowl', '\$4'),
('Smoothie Bowl', '\$7'),
('Egg White Omelette', '\$6'),
('Fruit Salad', '\$3');
EOF

# 5. Initialize git and push to GitHub (requires gh CLI and login)
git init
git add .
git commit -m "Initial 3-tier breakfast shop app"
gh repo create $GITHUB_USER/$REPO_NAME --public --source=. --remote=origin --push

# 6. Deploy to Render (manual step, but print instructions)
echo "=========================================="
echo "To deploy:"
echo "1. Create a PostgreSQL instance on Render (or AWS RDS)."
echo "2. Deploy the backend on Render as a Web Service (Node.js, set DATABASE_URL env var to your DB)."
echo "3. Deploy the frontend on Render as a Static Site (build with React)."
echo "4. Set frontend to call backend's Render URL for /api/menu."
echo "=========================================="
