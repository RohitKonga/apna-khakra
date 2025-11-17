# Troubleshooting GitHub Actions Failures

## Common Issues and Solutions

### 1. Flutter Build Fails

**Error:** `flutter build web` fails

**Solutions:**
- Check if all dependencies are compatible
- Verify Flutter version compatibility
- Check for syntax errors in code

**Fix:**
```bash
# Test locally first
flutter pub get
flutter build web --release
```

### 2. Missing API_URL Secret

**Error:** Build succeeds but frontend can't connect to backend

**Solution:**
1. Go to GitHub → Settings → Secrets → Actions
2. Verify `API_URL` is set to your Render backend URL
3. Format: `https://your-service.onrender.com` (no trailing slash)

### 3. GitHub Pages Deployment Fails

**Error:** `peaceiris/actions-gh-pages` fails

**Solutions:**
- Check repository permissions
- Ensure GitHub Actions has write access
- Verify the workflow is running on `main` branch

**Fix:**
1. Go to Settings → Actions → General
2. Under "Workflow permissions", select "Read and write permissions"
3. Save and re-run the workflow

### 4. Flutter Version Not Found

**Error:** `Flutter version '3.24.0' not found`

**Solution:**
- Use a stable Flutter version (updated to 3.22.0 in workflow)
- Check available versions: https://docs.flutter.dev/release/archive

### 5. Build Directory Not Found

**Error:** `publish_dir: ./build/web` not found

**Solution:**
- Ensure `flutter build web` completes successfully
- Check if build directory exists after build step

### 6. CORS Errors in Browser

**Error:** CORS policy blocking requests

**Solution:**
- Update `FRONTEND_URL` in Render environment variables
- Set to: `https://rohitkonga.github.io/apna-khakra`
- Restart Render service

## How to Debug

### View Workflow Logs
1. Go to: https://github.com/RohitKonga/apna-khakra/actions
2. Click on the failed workflow
3. Click on the failed job
4. Expand each step to see detailed logs

### Test Locally
```bash
# Install dependencies
flutter pub get

# Build web
flutter build web --release --dart-define=API_URL=https://your-render-url.onrender.com

# Check if build directory exists
ls -la build/web
```

### Check GitHub Secrets
1. Go to: https://github.com/RohitKonga/apna-khakra/settings/secrets/actions
2. Verify `API_URL` exists and is correct
3. Format should be: `https://your-service.onrender.com`

## Quick Fixes

### Re-run Workflow
1. Go to Actions tab
2. Click on failed workflow
3. Click "Re-run all jobs"

### Clear Cache
The workflow now includes `cache: true` for Flutter dependencies. If issues persist:
1. Go to Actions tab
2. Click on workflow
3. Click "..." → "Delete workflow run" (if needed)

### Update Workflow
If the workflow file was updated, push again:
```bash
git add .github/workflows/frontend.yml
git commit -m "Fix GitHub Actions workflow"
git push origin main
```

