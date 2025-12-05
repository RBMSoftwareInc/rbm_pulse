#!/bin/bash

# Deploy RBM-Pulse to Surge.sh (FREE - NO QUOTA LIMITS!)
# This script builds and deploys your Flutter web app to Surge.sh

set -e

echo "🌐 Deploying RBM-Pulse to Surge.sh..."
echo ""

cd "$(dirname "$0")"

# Check if Surge is installed
if ! command -v surge &> /dev/null; then
    echo "📦 Installing Surge CLI..."
    npm install -g surge
fi

# Build web app with environment variables
echo "🔨 Building web app with credentials..."
./build_web_with_env.sh

# Deploy to Surge
echo ""
echo "🚀 Deploying to Surge.sh..."
echo ""
echo "If this is your first time, you'll need to:"
echo "1. Create a free account (will be prompted)"
echo "2. Choose a subdomain (e.g., rbm-pulse.surge.sh)"
echo "3. Enter email and password when prompted"
echo ""

cd build/web
surge

echo ""
echo "✅ Deployment complete!"
echo "🌐 Your app is live at the URL shown above"
echo ""
echo "💡 To update, just run this script again!"

