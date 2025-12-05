#!/bin/bash

# Deploy RBM-Pulse to Netlify (FREE)
# This script builds and deploys your Flutter web app to Netlify

set -e

echo "🌐 Deploying RBM-Pulse to Netlify..."
echo ""

cd "$(dirname "$0")"

# Check if Netlify CLI is installed
if ! command -v netlify &> /dev/null; then
    echo "📦 Installing Netlify CLI..."
    npm install -g netlify-cli
fi

# Build web app
echo "🔨 Building web app..."
flutter build web --release

# Deploy to Netlify
echo "🚀 Deploying to Netlify..."
echo ""
echo "If this is your first time, you'll need to:"
echo "1. Login to Netlify (browser will open)"
echo "2. Authorize the CLI"
echo ""

netlify deploy --prod --dir=build/web

echo ""
echo "✅ Deployment complete!"
echo "🌐 Your app is live at the URL shown above"

