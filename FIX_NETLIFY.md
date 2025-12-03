# 🔧 Quick Fix for Netlify Deployment

## The Problem
Your app is trying to load `.env` file which doesn't work on web. The errors show:
- `GET https://rbmpulse.netlify.app/assets/.env 404 (Not Found)`
- JavaScript runtime error

## ✅ Solution (2 Options)

### Option 1: Set Environment Variables in Netlify (Recommended)

1. **Go to Netlify Dashboard:**
   - https://app.netlify.com
   - Select your site: `rbmpulse.netlify.app`
   - Go to **Site settings** → **Environment variables**

2. **Add These Variables:**
   ```
   SUPABASE_URL = your_supabase_url
   SUPABASE_ANON_KEY = your_supabase_anon_key
   ATTENTION_CHECK_MIN_DAYS = 10
   ATTENTION_CHECK_MAX_DAYS = 14
   AGGREGATION_MIN_GROUP = 10
   ```

3. **Redeploy:**
   - Go to **Deploys** tab
   - Click **Trigger deploy** → **Deploy site**

### Option 2: Rebuild with Environment Variables

1. **Rebuild with flags:**
   ```bash
   flutter build web --release \
     --dart-define=SUPABASE_URL=your_url \
     --dart-define=SUPABASE_ANON_KEY=your_key
   ```

2. **Redeploy the `build/web` folder to Netlify**

## 🔍 Find Your Supabase Credentials

1. Go to Supabase Dashboard → Your Project
2. Settings → API
3. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`

## ✅ What I Fixed

- ✅ Removed `.env` from assets (doesn't work on web)
- ✅ Updated code to handle web environment variables
- ✅ Made dotenv loading optional for web

## 🚀 Quick Steps

1. **Set environment variables in Netlify** (Option 1 above)
2. **Redeploy** - your app will work!

The code is now fixed to use environment variables properly on web! 🎉

