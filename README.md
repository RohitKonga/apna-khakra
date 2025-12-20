# Apna Khakra - E-commerce Platform

A full-stack e-commerce platform built with Flutter (web + mobile ready) and Node.js + Express, featuring a beautiful storefront and admin CRUD panel.

## 🚀 Features

- **Public Storefront**: Browse products, add to cart, and place orders
- **Shopping Cart**: Add/remove items, update quantities
- **Checkout Flow**: Collect customer information and create orders
- **Admin Panel**: Secure admin dashboard with product and order management
- **Responsive Design**: Works on mobile, tablet, and desktop
- **CI/CD**: Automated deployment via GitHub Actions

## 📁 Project Structure

```
apna_khakra/
├── backend-express/          # Node.js + Express API
│   ├── src/
│   │   ├── controllers/      # Request handlers
│   │   ├── models/           # MongoDB schemas
│   │   ├── routes/           # API routes
│   │   ├── middlewares/      # Auth middleware
│   │   ├── services/         # Business logic
│   │   └── scripts/          # Seed scripts
│   └── package.json
├── lib/                      # Flutter frontend
│   ├── src/
│   │   ├── screens/         # UI screens
│   │   ├── widgets/         # Reusable widgets
│   │   ├── models/          # Data models
│   │   ├── services/        # API service
│   │   ├── state/           # State management (Provider)
│   │   └── utils/           # Utilities
│   └── main.dart
└── .github/workflows/        # CI/CD workflows
```

## 🛠️ Tech Stack

- **Frontend**: Flutter (Web + Mobile)
- **Backend**: Node.js + Express
- **Database**: MongoDB Atlas
- **State Management**: Provider
- **Deployment**: GitHub Pages (Frontend), Render/Railway (Backend)

## 📋 Prerequisites

- Node.js 18+ and npm
- Flutter SDK 3.0+
- MongoDB Atlas account (free tier available)
- GitHub account

## 🔧 Setup Instructions

### 1. MongoDB Atlas Setup

1. Create a free MongoDB Atlas account at [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Create a new cluster (free tier: M0)
3. Create a database user with username and password
4. Whitelist IP address (use `0.0.0.0/0` for development, restrict in production)
5. Get your connection string: `mongodb+srv://<user>:<pass>@cluster0.xxxxx.mongodb.net/shopdb?retryWrites=true&w=majority`

### 2. Backend Setup

```bash
cd backend-express
npm install
```

Create `.env` file:
```env
MONGODB_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your-super-secret-jwt-key-change-this
PORT=5000
NODE_ENV=development
ADMIN_PASSWORD=admin123
FRONTEND_URL=http://localhost:3000
```

Seed the database:
```bash
npm run seed
```

Start the server:
```bash
npm run dev
```

The API will be available at `http://localhost:5000`

### 3. Frontend Setup

```bash
flutter pub get
```

For local development, use build-time variable:
```bash
flutter run -d chrome --dart-define=API_URL=http://localhost:5000
```

**For production:** The API URL is automatically set from GitHub Secrets (`API_URL`) during GitHub Actions build. No manual changes needed!

### 4. Admin Access

After seeding, login with:
- **Email**: ``
- **Password**: `` (or the password you set in `.env`)

## 🌐 Deployment

### Frontend (GitHub Pages)

1. Set GitHub Secrets:
   - `API_URL`: Your backend API URL
   - `CUSTOM_DOMAIN`: (Optional) Your custom domain

2. Push to `main` branch - GitHub Actions will automatically deploy

### Backend (Render)

1. Create a new Web Service on Render
2. Connect your GitHub repository
3. Set build command: `cd backend-express && npm install`
4. Set start command: `cd backend-express && npm start`
5. Add environment variables in Render dashboard
6. Get Render API key and service ID
7. Add to GitHub Secrets:
   - `RENDER_API_KEY`
   - `RENDER_SERVICE_ID`

### Backend (Railway)

1. Create new project on Railway
2. Connect GitHub repository
3. Add environment variables
4. Deploy automatically on push

## 📚 API Endpoints

### Public
- `GET /api/products` - List all products
- `GET /api/products/:id` - Get product details
- `POST /api/orders` - Create new order

### Auth
- `POST /api/auth/login` - Admin login

### Admin (Protected)
- `POST /api/products` - Create product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `GET /api/orders` - List all orders
- `GET /api/orders/:id` - Get order details
- `PATCH /api/orders/:id` - Update order status

## 🎓 GitHub Student Developer Pack Benefits

As a GitHub Student, you have access to:

### Free Credits & Services:
1. **MongoDB Atlas**: Free M0 cluster (512MB storage) - Perfect for this project
2. **Render**: Free tier with 750 hours/month - Host your backend
3. **Railway**: $5/month credit - Alternative backend hosting
4. **GitHub Pages**: Free hosting for static sites - Host Flutter web build
5. **Vercel**: Free tier - Alternative frontend hosting
6. **DigitalOcean**: $200 credit - Alternative hosting option
7. **Heroku**: (Limited free tier) - Alternative backend hosting

### Recommended Setup:
- **Database**: MongoDB Atlas (Free M0 cluster)
- **Backend**: Render (Free tier) or Railway ($5 credit)
- **Frontend**: GitHub Pages (Free) or Vercel (Free tier)

### How to Use:
1. Sign up at [education.github.com/pack](https://education.github.com/pack)
2. Verify your student status
3. Activate benefits for each service
4. Use the free credits for hosting and services

## 🧪 Testing

### Backend
```bash
cd backend-express
npm test  # Add tests as needed
```

### Frontend
```bash
flutter test
```

## 📝 Environment Variables

### Backend (.env)
- `MONGODB_URI` - MongoDB Atlas connection string
- `JWT_SECRET` - Secret for JWT tokens
- `PORT` - Server port (default: 5000)
- `ADMIN_PASSWORD` - Initial admin password for seed
- `FRONTEND_URL` - Frontend URL for CORS

### Frontend (Build-time)
- `API_URL` - Backend API URL (via --dart-define)

## 🔒 Security Notes

- Never commit `.env` files
- Use strong JWT secrets in production
- Restrict MongoDB Atlas IP whitelist in production
- Use HTTPS in production
- Implement rate limiting for production
- Add input validation and sanitization

## 📄 License

This project is open source and available for educational purposes.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions, please open an issue on GitHub.

---

Built with ❤️ using Flutter and Node.js
