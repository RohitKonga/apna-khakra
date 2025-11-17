# GitHub Student Developer Pack - Benefits for Apna Khakra

As a GitHub Student, you have access to amazing free tools and services perfect for building and deploying Apna Khakra!

## 🎁 Free Services You Can Use

### 1. **MongoDB Atlas** ⭐ RECOMMENDED
- **What you get**: Free M0 cluster (512MB storage)
- **Perfect for**: Database hosting
- **How to use**:
  1. Sign up at [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
  2. Verify with GitHub Student Pack
  3. Create free M0 cluster
  4. Use connection string in your `.env` file
- **Why it's great**: Managed MongoDB, no server setup needed!

### 2. **Render** ⭐ RECOMMENDED
- **What you get**: Free tier with 750 hours/month
- **Perfect for**: Backend API hosting
- **How to use**:
  1. Sign up at [render.com](https://render.com)
  2. Connect GitHub repo
  3. Deploy backend-express folder
  4. Add environment variables
- **Why it's great**: Auto-deploy from GitHub, free SSL, easy setup

### 3. **Railway** 
- **What you get**: $5/month credit
- **Perfect for**: Backend hosting (alternative to Render)
- **How to use**:
  1. Sign up at [railway.app](https://railway.app)
  2. Connect GitHub repo
  3. Deploy backend
- **Why it's great**: Simple deployment, good for Node.js apps

### 4. **GitHub Pages** ⭐ RECOMMENDED
- **What you get**: Free static site hosting
- **Perfect for**: Flutter web build
- **How to use**:
  1. Push code to GitHub
  2. Enable GitHub Pages in repo settings
  3. GitHub Actions auto-deploys on push
- **Why it's great**: Free, integrated with GitHub, custom domain support

### 5. **Vercel**
- **What you get**: Free tier (unlimited projects)
- **Perfect for**: Frontend hosting (alternative to GitHub Pages)
- **How to use**:
  1. Sign up at [vercel.com](https://vercel.com)
  2. Import GitHub repo
  3. Configure build settings
- **Why it's great**: Fast CDN, automatic deployments

### 6. **DigitalOcean**
- **What you get**: $200 credit (valid for 60 days)
- **Perfect for**: Full-stack hosting (if you need more control)
- **How to use**:
  1. Sign up at [digitalocean.com](https://digitalocean.com)
  2. Create Droplet (server)
  3. Deploy both frontend and backend
- **Why it's great**: Full server control, scalable

## 🏆 Recommended Setup (100% Free)

### Option 1: Maximum Free Tier
- **Database**: MongoDB Atlas (Free M0)
- **Backend**: Render (Free tier)
- **Frontend**: GitHub Pages (Free)
- **Total Cost**: $0/month ✅

### Option 2: With More Control
- **Database**: MongoDB Atlas (Free M0)
- **Backend**: Railway ($5 credit/month)
- **Frontend**: Vercel (Free tier)
- **Total Cost**: $0/month ✅

## 📋 Step-by-Step: Activate Your Benefits

1. **Visit**: [education.github.com/pack](https://education.github.com/pack)
2. **Sign in** with your GitHub account
3. **Verify** your student status (school email or student ID)
4. **Browse** available offers
5. **Activate** each service you want to use:
   - Click "Get your pack" for each service
   - Follow activation instructions
   - Some require separate sign-ups

## 🔧 How to Use in Apna Khakra

### MongoDB Atlas
```env
# In backend-express/.env
MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/shopdb?retryWrites=true&w=majority
```

### Render (Backend)
1. Create new Web Service
2. Connect GitHub repo
3. Root directory: `backend-express`
4. Build: `npm install`
5. Start: `npm start`
6. Add environment variables from `.env`

### GitHub Pages (Frontend)
1. Push code to GitHub
2. Settings → Pages → Enable
3. Source: `gh-pages` branch (created by GitHub Actions)
4. Your site: `https://yourusername.github.io/apna_khakra`

## 💡 Pro Tips

1. **Start with free tiers** - They're usually enough for development
2. **Use GitHub Actions** - Automate deployments (already set up!)
3. **Monitor usage** - Free tiers have limits
4. **Backup data** - Export MongoDB data regularly
5. **Use custom domains** - GitHub Pages and Vercel support them

## 🚨 Important Notes

- **Free tiers have limits** - Check each service's documentation
- **Student verification** - Some services require periodic re-verification
- **Credit expiration** - Some credits expire (e.g., DigitalOcean: 60 days)
- **Production ready?** - Free tiers are great for learning, consider paid for production

## 📚 Additional Resources

- [GitHub Student Pack](https://education.github.com/pack)
- [MongoDB Atlas Docs](https://docs.atlas.mongodb.com/)
- [Render Docs](https://render.com/docs)
- [GitHub Pages Docs](https://docs.github.com/en/pages)

---

**Happy Building! 🚀**

Use these free tools to build amazing projects like Apna Khakra!

