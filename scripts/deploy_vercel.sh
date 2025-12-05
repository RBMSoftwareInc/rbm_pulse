#!/bin/bash

# Deploy RBM-Pulse to Vercel (FREE)
# This script builds and deploys your Flutter web app to Vercel

set -e

echo "🌐 Deploying RBM-Pulse to Vercel..."
echo ""

cd "$(dirname "$0")"

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "📦 Installing Vercel CLI..."
    npm install -g vercel
fi

# Build web app with environment variables
echo "🔨 Building web app with credentials..."
./build_web_with_env.sh

# Deploy to Vercel
echo ""
echo "🚀 Deploying to Vercel..."
echo ""
echo "If this is your first time, you'll need to:"
echo "1. Login to Vercel (browser will open)"
echo "2. Follow the prompts"
echo ""

vercel --prod build/web

echo ""
echo "✅ Deployment complete!"
echo "🌐 Your app is live at the URL shown above"

