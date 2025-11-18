# How to Seed Production Database

## Method 1: Render Shell (Easiest)

1. Go to Render Dashboard → Your Backend Service
2. Click **"Shell"** tab
3. Run:
   ```bash
   cd backend-express
   npm run seed
   ```
4. Note the admin password shown in output

## Method 2: API Endpoint (Temporary)

1. Add `SEED_SECRET` to Render environment variables (any random string)
2. Call the endpoint:
   ```bash
   curl -X POST https://your-render-url.onrender.com/api/seed \
     -H "Content-Type: application/json" \
     -d '{"secret":"your-seed-secret"}'
   ```
3. **IMPORTANT:** Remove the seed route after use for security!

## Default Admin Credentials

After seeding:
- **Email:** `admin@apnakhakra.com`
- **Password:** Value of `ADMIN_PASSWORD` in Render (or `admin123` if not set)

## Check Your Render Environment Variables

Make sure `ADMIN_PASSWORD` is set in Render. If not set, default is `admin123`.

