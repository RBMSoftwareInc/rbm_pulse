# 🔧 Quick Fix for Web Error

## The Error
```
Uncaught Error at main.dart.js:3335
Missing required config value for SUPABASE_URL
```

## ✅ Solution: Set Environment Variables

Your app needs Supabase credentials. You have **2 options**:

### Option 1: Rebuild with Environment Variables (Recommended)

1. **Get your Supabase credentials:**
   - Go to Supabase Dashboard → Your Project
   - Settings → API
   - Copy **Project URL** and **anon public** key

2. **Rebuild with credentials:**
   ```bash
   cd /Users/rbmsoft/RBM/RBM-Pulse/rbm_pulse
   
   flutter build web --release \
     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=your_anon_key_here
   ```

3. **Redeploy to Netlify:**
   - Drag `build/web` folder to Netlify Drop
   - Or use: `./deploy_netlify.sh`

### Option 2: Set in Netlify Dashboard

1. **Go to Netlify:**
   - https://app.netlify.com
   - Select your site
   - **Site settings** → **Environment variables**

2. **Add these variables:**
   ```
   SUPABASE_URL = https://your-project.supabase.co
   SUPABASE_ANON_KEY = your_anon_key_here
   ATTENTION_CHECK_MIN_DAYS = 10
   ATTENTION_CHECK_MAX_DAYS = 14
   AGGREGATION_MIN_GROUP = 10
   ```

3. **Redeploy** (Netlify will rebuild automatically)

## 🎯 Which Option?

- **Option 1**: Faster, works immediately after redeploy
- **Option 2**: Better for continuous deployment, variables stored in Netlify

## ✅ What I Fixed

- ✅ Added better error messages
- ✅ Added error screen (shows helpful message instead of blank page)
- ✅ Improved environment variable handling

After setting the variables and redeploying, your app will work! 🎉

