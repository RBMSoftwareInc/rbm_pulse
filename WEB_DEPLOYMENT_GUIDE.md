# 🌐 Free Web Deployment Guide for RBM-Pulse

## ✅ Web Build Complete!

Your web app is built at: `build/web/`

## 🆓 Free Hosting Options

All these options are **100% FREE** for personal/internal projects:

### Option 1: Netlify (Easiest - Recommended) ⭐

**Free Features:**
- ✅ Free SSL certificate
- ✅ Custom domain support
- ✅ Continuous deployment from Git
- ✅ 100GB bandwidth/month
- ✅ 300 build minutes/month

**Deploy Steps:**

1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```

2. **Deploy:**
   ```bash
   cd /Users/rbmsoft/RBM/RBM-Pulse/rbm_pulse
   netlify deploy --prod --dir=build/web
   ```

3. **Or use Netlify Drop (No CLI needed):**
   - Go to https://app.netlify.com/drop
   - Drag and drop the `build/web` folder
   - Get instant URL!

### Option 2: Vercel (Fast & Easy)

**Free Features:**
- ✅ Free SSL
- ✅ Global CDN
- ✅ Automatic deployments
- ✅ 100GB bandwidth/month

**Deploy Steps:**

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Deploy:**
   ```bash
   cd /Users/rbmsoft/RBM/RBM-Pulse/rbm_pulse
   vercel --prod build/web
   ```

### Option 3: GitHub Pages (Free Forever)

**Free Features:**
- ✅ Free hosting
- ✅ Free SSL
- ✅ Custom domain
- ✅ Unlimited bandwidth

**Deploy Steps:**

1. **Create GitHub repository** (if you don't have one)

2. **Push your code:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin YOUR_GITHUB_REPO_URL
   git push -u origin main
   ```

3. **Enable GitHub Pages:**
   - Go to Settings → Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages`
   - Folder: `/ (root)`

4. **Deploy script:**
   ```bash
   ./deploy_github_pages.sh
   ```

### Option 4: Firebase Hosting (Google)

**Free Features:**
- ✅ 10GB storage
- ✅ 360MB/day transfer
- ✅ Free SSL
- ✅ Custom domain

**Deploy Steps:**

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login:**
   ```bash
   firebase login
   ```

3. **Initialize:**
   ```bash
   firebase init hosting
   # Select: Use an existing project or create new
   # Public directory: build/web
   # Single-page app: Yes
   ```

4. **Deploy:**
   ```bash
   firebase deploy --only hosting
   ```

### Option 5: Surge.sh (Simplest)

**Free Features:**
- ✅ Free SSL
- ✅ Custom subdomain
- ✅ Unlimited sites

**Deploy Steps:**

1. **Install Surge:**
   ```bash
   npm install -g surge
   ```

2. **Deploy:**
   ```bash
   cd build/web
   surge
   # Follow prompts to create account and deploy
   ```

## 🚀 Quick Deploy Scripts

I've created automated scripts for you - see below!

## 📝 Important Notes

1. **Environment Variables:**
   - Make sure your `.env` file has correct Supabase credentials
   - For production, set environment variables in your hosting platform

2. **CORS Settings:**
   - Update Supabase CORS settings to allow your web domain
   - Go to Supabase Dashboard → Settings → API → CORS

3. **Base URL:**
   - Update any hardcoded URLs in your code
   - Use relative paths where possible

## 🔒 Security

- Never commit `.env` file to Git
- Use environment variables in hosting platform
- Enable HTTPS (all platforms provide free SSL)

## 📊 Comparison

| Platform | Ease | Speed | Custom Domain | Best For |
|----------|------|-------|---------------|----------|
| Netlify | ⭐⭐⭐⭐⭐ | Fast | ✅ Free | Easiest |
| Vercel | ⭐⭐⭐⭐⭐ | Very Fast | ✅ Free | Performance |
| GitHub Pages | ⭐⭐⭐ | Medium | ✅ Free | Open Source |
| Firebase | ⭐⭐⭐⭐ | Fast | ✅ Free | Google Ecosystem |
| Surge | ⭐⭐⭐⭐ | Fast | ✅ Free | Quick Testing |

## 🎯 Recommended: Netlify Drop

**Fastest way to go live in 2 minutes:**

1. Build: `flutter build web`
2. Go to: https://app.netlify.com/drop
3. Drag `build/web` folder
4. Get URL instantly!

**That's it!** 🎉

