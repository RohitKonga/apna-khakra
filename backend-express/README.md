# Apna Khakra - Backend API

Node.js + Express backend for Apna Khakra e-commerce platform.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file (copy from `.env.example`):
```
MONGODB_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your-secret-key-change-this
PORT=5000
NODE_ENV=development
ADMIN_PASSWORD=admin123
FRONTEND_URL=http://localhost:3000
# For production on Render, use: FRONTEND_URL=https://your-username.github.io/apna-khakra
```

3. Seed database with initial product and admin:
```bash
npm run seed
```

4. Start development server:
```bash
npm run dev
```

## API Endpoints

### Public Endpoints

- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID
- `POST /api/orders` - Create new order

### Auth Endpoints

- `POST /api/auth/login` - Admin login
  - Body: `{ "email": "admin@apnakhakra.com", "password": "admin123" }`
  - Returns: `{ "token": "...", "email": "..." }`

### Admin Endpoints (Require Bearer token in Authorization header)

- `POST /api/products` - Create product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `GET /api/orders` - Get all orders
- `GET /api/orders/:id` - Get order by ID
- `PATCH /api/orders/:id` - Update order status
  - Body: `{ "status": "processing" | "shipped" | "delivered" | "cancelled" }`

## Environment Variables

- `MONGODB_URI` - MongoDB Atlas connection string
- `JWT_SECRET` - Secret key for JWT tokens
- `PORT` - Server port (default: 5000)
- `NODE_ENV` - Environment (development/production)
- `ADMIN_PASSWORD` - Initial admin password for seed script
- `FRONTEND_URL` - Frontend URL for CORS

