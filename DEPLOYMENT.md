# Deployment Guide - Apna Khakra

Complete step-by-step guide to deploy your e-commerce platform.

## 📋 Prerequisites

- GitHub account
- MongoDB Atlas account (already set up ✅)
- Render account (for backend) OR Railway account
- GitHub Student Pack activated (optional but recommended)

---

## Step 1: Push to GitHub

### 1.1 Create GitHub Repository

1. Go to [github.com](https://github.com) and sign in
2. Click the **"+"** icon → **"New repository"**
3. Repository name: `apna-khakra` (or any name you prefer)
4. Description: "E-commerce platform built with Flutter and Node.js"
5. Choose **Public** or **Private**
6. **DO NOT** initialize with README, .gitignore, or license (we already have these)
7. Click **"Create repository"**

### 1.2 Push Your Code

Run these commands in your terminal (from project root):

```bash
# Add the remote repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/apna-khakra.git

# Push to GitHub
git push -u origin main
```

**Note:** If you get an error about authentication, you may need to:
- Use a Personal Access Token instead of password
- Or set up SSH keys
- Or use GitHub CLI: `gh auth login`

---

## Step 2: Configure GitHub Secrets

GitHub Secrets store sensitive information that your GitHub Actions workflows need.

### 2.1 Access GitHub Secrets

1. Go to your repository on GitHub
2. Click **Settings** (top menu)
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **"New repository secret"**

### 2.2 Required Secrets

Add these secrets one by one:

#### For Frontend Deployment:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `API_URL` | `https://your-backend-url.onrender.com` | Your backend API URL (you'll get this after deploying backend) |

**Note:** If you haven't deployed backend yet, you can add this later or use a placeholder.

#### For Backend Deployment (Render):

| Secret Name | Value | How to Get |
|------------|-------|------------|
| `RENDER_API_KEY` | Your Render API key | See section 3.1 below |
| `RENDER_SERVICE_ID` | Your Render service ID | See section 3.2 below |

#### For Backend Deployment (Railway - Alternative):

| Secret Name | Value | How to Get |
|------------|-------|------------|
| `RAILWAY_TOKEN` | Your Railway token | Railway dashboard → Settings → Tokens |
| `RAILWAY_SERVICE_ID` | Your Railway service ID | Railway dashboard |

#### Optional:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `CUSTOM_DOMAIN` | `yourdomain.com` | If you have a custom domain for GitHub Pages |

---

## Step 3: Deploy Backend to Render

### 3.1 Get Render API Key

1. Sign up at [render.com](https://render.com) (use GitHub Student Pack for free tier)
2. Go to [Account Settings](https://dashboard.render.com/account)
3. Scroll to **API Keys** section
4. Click **"Create API Key"**
5. Give it a name (e.g., "GitHub Actions")
6. Copy the API key (you won't see it again!)
7. Add it to GitHub Secrets as `RENDER_API_KEY`

### 3.2 Create Render Web Service

1. In Render dashboard, click **"New +"** → **"Web Service"**
2. Connect your GitHub account if not already connected
3. Select your `apna-khakra` repository
4. Configure the service:
   - **Name**: `apna-khakra-backend` (or any name)
   - **Root Directory**: `backend-express`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
5. Click **"Advanced"** and add **Environment Variables**:
   ```
   MONGODB_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret
   PORT=10000
   NODE_ENV=production
   FRONTEND_URL=https://your-username.github.io/apna-khakra
   ```
6. Click **"Create Web Service"**
7. Wait for deployment (takes 2-5 minutes)
8. Once deployed, copy your service URL (e.g., `https://apna-khakra-backend.onrender.com`)
9. Go to **Settings** → **Service Details** → Copy the **Service ID**
10. Add `RENDER_SERVICE_ID` to GitHub Secrets

### 3.3 Update API_URL Secret

1. Go back to GitHub Secrets
2. Update `API_URL` with your Render backend URL: `https://your-service.onrender.com`

---

## Step 4: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages** (left sidebar)
3. Under **Source**, select:
   - Branch: `gh-pages`
   - Folder: `/ (root)`
4. Click **"Save"**
5. Your site will be available at: `https://YOUR_USERNAME.github.io/apna-khakra`

**Note:** The `gh-pages` branch will be created automatically by GitHub Actions on first deployment.

---

## Step 5: Test the Deployment

### 5.1 Test Backend

1. Visit your Render service URL
2. Add `/api/health` to the end: `https://your-service.onrender.com/api/health`
3. You should see: `{"status":"OK","message":"Apna Khakra API is running"}`

### 5.2 Test Frontend

1. After pushing to `main`, GitHub Actions will automatically:
   - Build your Flutter web app
   - Deploy to GitHub Pages
2. Check the **Actions** tab in your GitHub repo to see the workflow progress
3. Once complete, visit: `https://YOUR_USERNAME.github.io/apna-khakra`

### 5.3 Update Frontend Config

If your frontend is deployed but can't connect to backend:

1. Update `lib/src/utils/config.dart`:
   ```dart
   static const String apiUrl = 'https://your-backend-url.onrender.com';
   ```
2. Or update the GitHub Secret `API_URL` and push again

---

## Step 6: Verify Everything Works

1. ✅ Backend API is accessible
2. ✅ Frontend loads on GitHub Pages
3. ✅ Frontend can fetch products from backend
4. ✅ Admin login works
5. ✅ Orders can be created

---

## 🔧 Troubleshooting

### GitHub Actions Fails

**Problem:** Workflow fails with "API_URL not found"
- **Solution:** Make sure you added `API_URL` secret in GitHub Settings

**Problem:** Frontend build fails
- **Solution:** Check the Actions log for specific errors
- Common issues: Missing dependencies, Flutter version mismatch

### Backend Deployment Fails

**Problem:** Render deployment fails
- **Solution:** 
  - Check Render logs for errors
  - Verify environment variables are set correctly
  - Make sure `MONGODB_URI` is correct

**Problem:** Backend can't connect to MongoDB
- **Solution:**
  - Check MongoDB Atlas Network Access (whitelist IPs)
  - Verify connection string is correct
  - Check MongoDB Atlas cluster is running

### Frontend Can't Connect to Backend

**Problem:** CORS errors in browser console
- **Solution:** 
  - Update `FRONTEND_URL` in Render environment variables
  - Make sure it matches your GitHub Pages URL

**Problem:** API calls return 404
- **Solution:**
  - Verify `API_URL` in GitHub Secrets matches your backend URL
  - Check backend is running on Render

---

## 📝 Quick Reference

### GitHub Secrets Checklist

- [ ] `API_URL` - Backend API URL
- [ ] `RENDER_API_KEY` - Render API key (if using Render)
- [ ] `RENDER_SERVICE_ID` - Render service ID (if using Render)
- [ ] `RAILWAY_TOKEN` - Railway token (if using Railway)
- [ ] `RAILWAY_SERVICE_ID` - Railway service ID (if using Railway)
- [ ] `CUSTOM_DOMAIN` - Custom domain (optional)

### Render Environment Variables Checklist

- [ ] `MONGODB_URI` - MongoDB connection string
- [ ] `JWT_SECRET` - JWT secret key
- [ ] `PORT` - Port (usually 10000 for Render)
- [ ] `NODE_ENV` - Set to `production`
- [ ] `FRONTEND_URL` - Your GitHub Pages URL

---

## 🎉 Success!

Once everything is deployed:
- Your frontend is live on GitHub Pages
- Your backend is running on Render/Railway
- GitHub Actions auto-deploys on every push to `main`
- Your e-commerce platform is live! 🚀

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Render Documentation](https://render.com/docs)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com/)

---

**Need help?** Check the troubleshooting section or open an issue on GitHub!

