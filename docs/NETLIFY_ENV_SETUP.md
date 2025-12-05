# 🔧 Fix Netlify Environment Variables

## The Problem
Your app is trying to load `.env` file which doesn't work on web. For web deployments, you need to set environment variables in Netlify.

## ✅ Solution: Set Environment Variables in Netlify

### Step 1: Go to Netlify Dashboard
1. Go to https://app.netlify.com
2. Select your site: `rbmpulse.netlify.app`
3. Go to **Site settings** → **Environment variables**

### Step 2: Add These Variables

Click **Add variable** and add each of these:

```
SUPABASE_URL = your_supabase_url_here
SUPABASE_ANON_KEY = your_supabase_anon_key_here
ATTENTION_CHECK_MIN_DAYS = 10
ATTENTION_CHECK_MAX_DAYS = 14
AGGREGATION_MIN_GROUP = 10
```

### Step 3: Redeploy

After adding the variables:
1. Go to **Deploys** tab
2. Click **Trigger deploy** → **Deploy site**
3. Wait for deployment to complete

## 🔍 How to Find Your Supabase Credentials

1. Go to your Supabase project dashboard
2. Go to **Settings** → **API**
3. Copy:
   - **Project URL** → Use as `SUPABASE_URL`
   - **anon public** key → Use as `SUPABASE_ANON_KEY`

## 🚀 Quick Fix Script

I've updated the code to handle web environment variables properly. Now:

1. **Rebuild your web app:**
   ```bash
   flutter build web --release
   ```

2. **Redeploy to Netlify:**
   - Either drag `build/web` to Netlify Drop again
   - Or use: `./deploy_netlify.sh`

3. **Set environment variables in Netlify** (as shown above)

## ✅ What I Fixed

- ✅ Removed `.env` from assets (doesn't work on web)
- ✅ Updated code to use environment variables on web
- ✅ Made dotenv loading optional for web platform

Your app will now work once you set the environment variables in Netlify!

