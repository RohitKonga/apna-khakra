# How to Seed Production Database on Render

## Option 1: Using Render Shell (Recommended)

1. Go to your Render dashboard
2. Click on your backend service
3. Click on **"Shell"** tab (or look for "Open Shell" button)
4. Run these commands:

```bash
cd backend-express
npm run seed
```

5. You should see:
   ```
   Connected to MongoDB
   Cleared existing data
   Created seed product: Premium Khakra
   Created admin user: admin@apnakhakra.com
   Admin password: [your password]
   ✅ Seed data created successfully!
   ```

## Option 2: Add Seed Script to Render Build

If Render shell doesn't work, you can modify the start script to seed on first run.

**Note:** This will seed every time the service restarts. Only use if needed.

## Option 3: Create Admin via API (Temporary)

Create a temporary endpoint to seed (remove after use for security).

## Default Admin Credentials

After seeding, use:
- **Email:** `admin@apnakhakra.com`
- **Password:** The value of `ADMIN_PASSWORD` in your Render environment variables (or `admin123` if not set)

## Verify Environment Variables in Render

Make sure these are set in Render:
- `MONGODB_URI` - Your MongoDB connection string
- `ADMIN_PASSWORD` - Password for admin user (defaults to `admin123` if not set)
- `JWT_SECRET` - Your JWT secret

## Troubleshooting

### "Cannot connect to MongoDB"
- Check `MONGODB_URI` is correct in Render
- Verify MongoDB Atlas Network Access allows Render's IPs (or use 0.0.0.0/0 for development)

### "Admin already exists"
- The seed script clears existing admins, so this shouldn't happen
- If it does, you can manually delete the admin from MongoDB Atlas

