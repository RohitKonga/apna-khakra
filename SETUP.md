# Quick Setup Guide - Apna Khakra

## 🚀 Quick Start (5 minutes)

### Step 1: MongoDB Atlas Setup

1. Go to [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Sign up (use GitHub Student Pack for free credits)
3. Create a free M0 cluster
4. Click "Connect" → "Connect your application"
5. Copy the connection string (looks like: `mongodb+srv://user:pass@cluster0.xxxxx.mongodb.net/...`)
6. Replace `<password>` with your database user password

### Step 2: Backend Setup

```bash
cd backend-express
npm install
```

Create `.env` file:
```env
MONGODB_URI=mongodb+srv://your-connection-string-here
JWT_SECRET=your-super-secret-key-12345
PORT=5000
ADMIN_PASSWORD=admin123
FRONTEND_URL=http://localhost:3000
```

Seed database:
```bash
npm run seed
```

Start server:
```bash
npm run dev
```

✅ Backend running at `http://localhost:5000`

### Step 3: Frontend Setup

```bash
# From project root
flutter pub get
```

Update API URL in `lib/src/utils/config.dart`:
```dart
static const String apiUrl = 'http://localhost:5000';
```

Or run with build-time variable:
```bash
flutter run -d chrome --dart-define=API_URL=http://localhost:5000
```

✅ Frontend running at `http://localhost:3000` (or Flutter's default port)

### Step 4: Test Admin Login

1. Open the app
2. Click the admin icon (top right)
3. Login with:
   - Email: `admin@apnakhakra.com`
   - Password: `admin123` (or your ADMIN_PASSWORD)

## 📦 Production Deployment

### Frontend (GitHub Pages)

1. Push code to GitHub
2. Go to Settings → Pages
3. Enable GitHub Pages
4. Add GitHub Secrets:
   - `API_URL`: Your backend URL
5. Push to `main` - auto-deploys!

### Backend (Render)

1. Sign up at [render.com](https://render.com)
2. New → Web Service
3. Connect GitHub repo
4. Settings:
   - Build: `cd backend-express && npm install`
   - Start: `cd backend-express && npm start`
5. Add environment variables
6. Deploy!

## 🎓 Using GitHub Student Pack

1. Visit [education.github.com/pack](https://education.github.com/pack)
2. Verify student status
3. Activate benefits:
   - **MongoDB Atlas**: Free M0 cluster
   - **Render**: Free tier (750 hrs/month)
   - **Railway**: $5/month credit
   - **GitHub Pages**: Free hosting
   - **Vercel**: Free tier

## 🐛 Troubleshooting

### Backend won't start
- Check MongoDB connection string
- Ensure `.env` file exists
- Check if port 5000 is available

### Frontend can't connect to backend
- Verify API_URL in `config.dart`
- Check CORS settings in backend
- Ensure backend is running

### Admin login fails
- Run seed script: `npm run seed` in backend-express
- Check admin credentials in `.env`

## 📝 Next Steps

- Add payment integration (Stripe)
- Add product images upload
- Add email notifications
- Add order tracking
- Add user accounts
- Add product reviews

---

Need help? Open an issue on GitHub!

