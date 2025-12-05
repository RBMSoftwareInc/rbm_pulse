#!/bin/bash

# Build Flutter Web App
# This script builds your Flutter app for web deployment

set -e

echo "🌐 Building RBM-Pulse for Web..."
echo ""

cd "$(dirname "$0")"

# Check if .env exists and use it for build
if [ -f ".env" ]; then
    echo "📖 Found .env file, using it for build..."
    ./build_web_with_env.sh
    exit 0
fi

# Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build web app (without env vars - will show error screen)
echo "⚠️  No .env file found. Building without environment variables..."
echo "   The app will show an error screen until you rebuild with credentials."
echo ""
echo "🔨 Building web app (this may take a few minutes)..."
flutter build web --release

echo ""
echo "✅ Build complete!"
echo "📁 Web files are in: build/web/"
echo ""
echo "⚠️  IMPORTANT: This build doesn't have Supabase credentials."
echo "   To build with credentials, run: ./build_web_with_env.sh"
echo ""
echo "🚀 To deploy, run one of:"
echo "   ./deploy_netlify.sh    (Easiest - Recommended)"
echo "   ./deploy_vercel.sh     (Fast CDN)"
echo "   ./deploy_surge.sh      (Quick testing)"
echo "   ./deploy_github_pages.sh (Free forever)"
echo ""
echo "💡 Or manually upload build/web/ to any hosting service"

