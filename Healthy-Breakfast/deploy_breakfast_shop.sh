#!/bin/bash

# Variables
REPO_NAME="healthy-breakfast-shop"
GITHUB_USER="sanjayhar"
RENDER_SERVICE_NAME="breakfast-shop"
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"
DB_DIR="database"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function for colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI is not authenticated. Please run 'gh auth login' first."
        exit 1
    fi
    
    if ! command -v node &> /dev/null; then
        print_warning "Node.js is not installed. You'll need it for local development."
    fi
    
    print_status "Prerequisites check completed."
}

# 1. Create repo directories
create_directories() {
    print_status "Creating project directories..."
    
    if [ -d "$REPO_NAME" ]; then
        print_error "Directory $REPO_NAME already exists. Please remove it or choose a different name."
        exit 1
    fi
    
    mkdir -p $REPO_NAME/$FRONTEND_DIR/public
    mkdir -p $REPO_NAME/$FRONTEND_DIR/src
    mkdir -p $REPO_NAME/$BACKEND_DIR
    mkdir -p $REPO_NAME/$DB_DIR
    
    cd $REPO_NAME
    print_status "Directories created successfully."
}

# 2. Create improved frontend (React with proper build setup)
create_frontend() {
    print_status "Setting up React frontend..."
    
    cat > $FRONTEND_DIR/package.json <<EOF
{
  "name": "breakfast-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

    cat > $FRONTEND_DIR/src/App.js <<EOF
import React, { useState, useEffect } from "react";
import './App.css';

const App = () => {
  const [menu, setMenu] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Default menu items (fallback)
  const defaultMenu = [
    { name: "Avocado Toast", price: "$6" },
    { name: "Greek Yogurt Parfait", price: "$5" },
    { name: "Oatmeal Bowl", price: "$4" },
    { name: "Smoothie Bowl", price: "$7" },
    { name: "Egg White Omelette", price: "$6" },
    { name: "Fruit Salad", price: "$3" }
  ];

  useEffect(() => {
    fetchMenu();
  }, []);

  const fetchMenu = async () => {
    try {
      const backendUrl = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8080';
      const response = await fetch(\`\${backendUrl}/api/menu\`);
      
      if (!response.ok) {
        throw new Error('Failed to fetch menu');
      }
      
      const data = await response.json();
      setMenu(data);
    } catch (err) {
      console.error('Error fetching menu:', err);
      setError(err.message);
      setMenu(defaultMenu); // Use default menu as fallback
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="app">
        <div className="loading">Loading menu...</div>
      </div>
    );
  }

  return (
    <div className="app">
      <header className="header">
        <h1>🥑 Healthy Breakfast Shop 🥣</h1>
      </header>
      
      <main className="main">
        <div className="menu-container">
          <h2>Our Fresh Menu</h2>
          {error && (
            <div className="error-message">
              <p>⚠️ Using offline menu (couldn't connect to server)</p>
            </div>
          )}
          
          <div className="menu-grid">
            {menu.map((item, idx) => (
              <div key={idx} className="menu-item">
                <span className="item-name">{item.name}</span>
                <span className="item-price">{item.price}</span>
              </div>
            ))}
          </div>
          
          <div className="cta-section">
            <p>✨ Fresh, healthy, and delicious breakfast options!</p>
            <button className="order-button">Order Now</button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default App;
EOF

    cat > $FRONTEND_DIR/src/App.css <<EOF
.app {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
  margin: 0;
  padding: 0;
}

.header {
  background: linear-gradient(135deg, #ffb347 0%, #ff8c42 100%);
  color: white;
  text-align: center;
  padding: 2rem;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.header h1 {
  margin: 0;
  font-size: 2.5rem;
  font-weight: 700;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}

.main {
  padding: 2rem;
  display: flex;
  justify-content: center;
}

.menu-container {
  background: white;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.1);
  padding: 2rem;
  max-width: 600px;
  width: 100%;
}

.menu-container h2 {
  color: #ff8c42;
  text-align: center;
  margin-bottom: 2rem;
  font-size: 2rem;
}

.loading {
  text-align: center;
  padding: 4rem;
  font-size: 1.2rem;
  color: #666;
}

.error-message {
  background: #fff3cd;
  border: 1px solid #ffeaa7;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1rem;
  text-align: center;
}

.error-message p {
  margin: 0;
  color: #856404;
}

.menu-grid {
  display: grid;
  gap: 1rem;
  margin-bottom: 2rem;
}

.menu-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #ffb347;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.menu-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.item-name {
  font-weight: 600;
  color: #333;
  font-size: 1.1rem;
}

.item-price {
  font-weight: 700;
  color: #ff8c42;
  font-size: 1.2rem;
}

.cta-section {
  text-align: center;
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 1px solid #eee;
}

.cta-section p {
  color: #666;
  font-size: 1.1rem;
  margin-bottom: 1rem;
}

.order-button {
  background: linear-gradient(135deg, #ff8c42 0%, #ffb347 100%);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 50px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.order-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 140, 66, 0.3);
}

@media (max-width: 768px) {
  .header h1 {
    font-size: 2rem;
  }
  
  .main {
    padding: 1rem;
  }
  
  .menu-container {
    padding: 1.5rem;
  }
  
  .menu-item {
    flex-direction: column;
    text-align: center;
    gap: 0.5rem;
  }
}
EOF

    cat > $FRONTEND_DIR/src/index.js <<EOF
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

    cat > $FRONTEND_DIR/src/index.css <<EOF
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
EOF

    cat > $FRONTEND_DIR/public/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🥑</text></svg>">
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#ffb347" />
    <meta name="description" content="Healthy Breakfast Shop - Fresh, nutritious breakfast options" />
    <title>Healthy Breakfast Shop</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

    # Environment file template
    cat > $FRONTEND_DIR/.env.example <<EOF
# Backend API URL
REACT_APP_BACKEND_URL=http://localhost:8080

# For production, set this to your deployed backend URL
# REACT_APP_BACKEND_URL=https://your-backend-url.render.com
EOF

    print_status "Frontend setup completed."
}

# 3. Create improved backend (Node.js/Express with better error handling)
create_backend() {
    print_status "Setting up Node.js backend..."
    
    cat > $BACKEND_DIR/package.json <<EOF
{
  "name": "breakfast-backend",
  "version": "1.0.0",
  "description": "Backend API for Healthy Breakfast Shop",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.1",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  },
  "engines": {
    "node": ">=16.0.0"
  }
}
EOF

    cat > $BACKEND_DIR/server.js <<EOF
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Test database connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error connecting to database:', err.message);
    console.log('Server will start but database operations will fail');
  } else {
    console.log('✅ Database connected successfully');
    release();
  }
});

// Default menu items (fallback)
const defaultMenu = [
  { name: "Avocado Toast", price: "$6" },
  { name: "Greek Yogurt Parfait", price: "$5" },
  { name: "Oatmeal Bowl", price: "$4" },
  { name: "Smoothie Bowl", price: "$7" },
  { name: "Egg White Omelette", price: "$6" },
  { name: "Fruit Salad", price: "$3" }
];

// Routes
app.get('/', (req, res) => {
  res.json({ 
    message: 'Healthy Breakfast Shop API', 
    version: '1.0.0',
    endpoints: {
      menu: '/api/menu',
      health: '/api/health'
    }
  });
});

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get("/api/menu", async (req, res) => {
  try {
    const { rows } = await pool.query("SELECT name, price FROM menu ORDER BY name");
    
    if (rows.length === 0) {
      console.log('No menu items found in database, using default menu');
      res.json(defaultMenu);
    } else {
      res.json(rows);
    }
  } catch (error) {
    console.error('Database error:', error.message);
    
    // Return default menu if database is unavailable
    res.json(defaultMenu);
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Handle 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Start server
app.listen(port, () => {
  console.log(\`🚀 Server running on port \${port}\`);
  console.log(\`📱 API available at http://localhost:\${port}\`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  pool.end(() => {
    process.exit(0);
  });
});
EOF

    # Environment file template
    cat > $BACKEND_DIR/.env.example <<EOF
# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/breakfast_shop

# Server Configuration
PORT=8080
NODE_ENV=development

# For production, set NODE_ENV=production and use your actual database URL
EOF

    print_status "Backend setup completed."
}

# 4. Create database schema and initialization
create_database() {
    print_status "Setting up database schema..."
    
    cat > $DB_DIR/schema.sql <<EOF
-- Healthy Breakfast Shop Database Schema

-- Create menu table
CREATE TABLE IF NOT EXISTS menu (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price VARCHAR(10) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    ingredients TEXT[],
    calories INTEGER,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    menu_item_id INTEGER REFERENCES menu(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Insert sample menu data
INSERT INTO menu (name, price, description, category, ingredients, calories) VALUES
('Avocado Toast', '$6', 'Fresh avocado on whole grain bread with cherry tomatoes', 'Toast', ARRAY['avocado', 'whole grain bread', 'cherry tomatoes', 'olive oil'], 280),
('Greek Yogurt Parfait', '$5', 'Creamy Greek yogurt layered with berries and granola', 'Parfait', ARRAY['Greek yogurt', 'mixed berries', 'granola', 'honey'], 220),
('Oatmeal Bowl', '$4', 'Steel-cut oats topped with banana and almonds', 'Bowl', ARRAY['steel-cut oats', 'banana', 'almonds', 'cinnamon'], 350),
('Smoothie Bowl', '$7', 'Acai smoothie bowl with fresh fruits and seeds', 'Bowl', ARRAY['acai', 'banana', 'berries', 'chia seeds', 'coconut'], 300),
('Egg White Omelette', '$6', 'Fluffy egg white omelette with spinach and feta', 'Omelette', ARRAY['egg whites', 'spinach', 'feta cheese', 'herbs'], 180),
('Fruit Salad', '$3', 'Seasonal fresh fruit medley', 'Salad', ARRAY['mixed seasonal fruits', 'mint'], 120),
('Quinoa Bowl', '$8', 'Protein-packed quinoa with roasted vegetables', 'Bowl', ARRAY['quinoa', 'roasted vegetables', 'chickpeas', 'tahini'], 400),
('Chia Pudding', '$5', 'Overnight chia pudding with coconut milk and berries', 'Pudding', ARRAY['chia seeds', 'coconut milk', 'berries', 'maple syrup'], 250)
ON CONFLICT (name) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_menu_category ON menu(category);
CREATE INDEX IF NOT EXISTS idx_menu_available ON menu(is_available);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
EOF

    cat > $DB_DIR/seed.sql <<EOF
-- Additional sample data for development

-- Insert sample customers
INSERT INTO customers (name, email, phone) VALUES
('John Doe', 'john@example.com', '+1234567890'),
('Jane Smith', 'jane@example.com', '+1234567891'),
('Bob Johnson', 'bob@example.com', '+1234567892')
ON CONFLICT (email) DO NOTHING;

-- Insert sample orders
INSERT INTO orders (customer_id, total_amount, status) VALUES
(1, 18.00, 'completed'),
(2, 12.00, 'pending'),
(3, 25.00, 'completed');

-- Insert sample order items
INSERT INTO order_items (order_id, menu_item_id, quantity, price) VALUES
(1, 1, 2, 6.00),
(1, 2, 1, 5.00),
(2, 3, 3, 4.00),
(3, 4, 2, 7.00),
(3, 5, 1, 6.00),
(3, 6, 2, 3.00);
EOF

    cat > $DB_DIR/README.md <<EOF
# Database Setup

## Local Development

1. Install PostgreSQL locally
2. Create a database: \`createdb breakfast_shop\`
3. Run the schema: \`psql -d breakfast_shop -f schema.sql\`
4. Optional - Add sample data: \`psql -d breakfast_shop -f seed.sql\`

## Production Setup

1. Create a PostgreSQL instance on Render, AWS RDS, or similar
2. Get the connection string (DATABASE_URL)
3. Set the DATABASE_URL environment variable in your backend
4. The schema will be created automatically when the app starts

## Environment Variables

Set these environment variables in your backend:

- \`DATABASE_URL\`: PostgreSQL connection string
- \`NODE_ENV\`: Set to 'production' for production deployment
EOF

    print_status "Database setup completed."
}

# 5. Create deployment configuration
create_deployment_config() {
    print_status "Creating deployment configuration..."
    
    # Render deployment configuration
    cat > render.yaml <<EOF
services:
  # Database
  - type: pserv
    name: breakfast-db
    env: node
    plan: free
    databases:
      - name: breakfast_shop
        user: breakfast_user

  # Backend API
  - type: web
    name: breakfast-backend
    env: node
    plan: free
    buildCommand: cd backend && npm install
    startCommand: cd backend && npm start
    healthCheckPath: /api/health
    envVars:
      - key: NODE_ENV
        value: production
      - key: DATABASE_URL
        fromDatabase:
          name: breakfast_shop
          property: connectionString
    autoDeploy: false

  # Frontend
  - type: web
    name: breakfast-frontend
    env: static
    plan: free
    buildCommand: cd frontend && npm install && npm run build
    staticPublishPath: ./frontend/build
    envVars:
      - key: REACT_APP_BACKEND_URL
        fromService:
          type: web
          name: breakfast-backend
          property: url
    autoDeploy: false
EOF

    # Docker configuration (alternative deployment option)
    cat > Dockerfile <<EOF
# Multi-stage build for production
FROM node:18-alpine AS frontend-build

# Build frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci --only=production
COPY frontend/ ./
RUN npm run build

# Backend stage
FROM node:18-alpine AS backend

WORKDIR /app
COPY backend/package*.json ./
RUN npm ci --only=production

COPY backend/ ./
COPY --from=frontend-build /app/frontend/build ./public

EXPOSE 8080

CMD ["npm", "start"]
EOF

    cat > docker-compose.yml <<EOF
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: breakfast_shop
      POSTGRES_USER: breakfast_user
      POSTGRES_PASSWORD: breakfast_pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
      - ./database/seed.sql:/docker-entrypoint-initdb.d/02-seed.sql
    ports:
      - "5432:5432"

  backend:
    build: .
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: postgresql://breakfast_user:breakfast_pass@db:5432/breakfast_shop
      NODE_ENV: development
    depends_on:
      - db
    volumes:
      - ./backend:/app
      - /app/node_modules

volumes:
  postgres_data:
EOF

    print_status "Deployment configuration created."
}

# 6. Create project documentation
create_documentation() {
    print_status "Creating project documentation..."
    
    cat > README.md <<EOF
# 🥑 Healthy Breakfast Shop

A modern, full-stack web application for a healthy breakfast restaurant with React frontend, Node.js backend, and PostgreSQL database.

## 🚀 Features

- **Frontend**: Responsive React app with modern UI
- **Backend**: RESTful API with Express.js
- **Database**: PostgreSQL with structured schema
- **Deployment**: Ready for Render, Docker, or other platforms
- **Responsive Design**: Mobile-first approach
- **Error Handling**: Graceful fallbacks and user feedback

## 📋 Prerequisites

- Node.js (v16 or higher)
- PostgreSQL (for local development)
- GitHub CLI (for deployment)

## 🛠️ Local Development

### 1. Clone and Install

\`\`\`bash
git clone https://github.com/$GITHUB_USER/$REPO_NAME.git
cd $REPO_NAME
\`\`\`

### 2. Setup Backend

\`\`\`bash
cd backend
npm install
cp .env.example .env
# Edit .env with your database credentials
npm run dev
\`\`\`

### 3. Setup Frontend

\`\`\`bash
cd frontend
npm install
cp .env.example .env
# Edit .env with your backend URL
npm start
\`\`\`

### 4. Setup Database

\`\`\`bash
# Create database
createdb breakfast_shop

# Run schema
psql -d breakfast_shop -f database/schema.sql

# Optional: Add sample data
psql -d breakfast_shop -f database/seed.sql
\`\`\`

## 🚀 Deployment

### Option 1: Render (Recommended)

1. **Database**: Create a PostgreSQL instance on Render
2. **Backend**: Deploy as a Web Service
   - Build Command: \`cd backend && npm install\`
   - Start Command: \`cd backend && npm start\`
   - Environment Variables: Set \`DATABASE_URL\` and \`NODE_ENV=production\`
3. **Frontend**: Deploy as a Static Site
   - Build Command: \`cd frontend && npm install && npm run build\`
   - Publish Directory: \`frontend/build\`
   - Environment Variables: Set \`REACT_APP_BACKEND_URL\`

### Option 2: Docker

\`\`\`bash
docker-compose up -d
\`\`\`

### Option 3: Manual Deployment

Follow the instructions in the deployment section of this README.

## 🏗️ Architecture

\`\`\`
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   React App     │────│   Express API   │────│   PostgreSQL    │
│   (Frontend)    │    │   (Backend)     │    │   (Database)    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Project Structure

\`\`\`
$REPO_NAME/
├── frontend/                 # React application
│   ├── src/
│   │   ├── App.js           # Main component
│   │   ├── App.css          # Styles
│   │   └── index.js         # Entry point
│   ├── public/
│   │   └── index.html       # HTML template
│   └── package.json         # Dependencies
├── backend/                  # Node.js API
│   ├── server.js            # Express server
│   ├── .env.example         # Environment template
│   └── package.json         # Dependencies
├── database/                 # Database files
│   ├── schema.sql           # Database schema
│   ├── seed.sql             # Sample data
│   └── README.md            # Database docs
├── render.yaml              # Render deployment config
├── docker-compose.yml       # Docker setup
└── README.md                # This file
\`\`\`

## 🔧 API Endpoints

- \`GET /\` - API information
- \`GET /api/health\` - Health check
- \`GET /api/menu\` - Get menu items

## 🎨 UI Features

- Modern, responsive design
- Loading states
- Error handling with fallbacks
- Mobile-optimized layout
- Smooth animations and transitions

## 🔒 Environment Variables

### Backend (.env)
\`\`\`
DATABASE_URL=postgresql://user:pass@localhost:5432/breakfast_shop
PORT=8080
NODE_ENV=development
\`\`\`

### Frontend (.env)
\`\`\`
REACT_APP_BACKEND_URL=http://localhost:8080
\`\`\`

## 🧪 Testing

\`\`\`bash
# Backend tests
cd backend && npm test

# Frontend tests
cd frontend && npm test
\`\`\`

##
