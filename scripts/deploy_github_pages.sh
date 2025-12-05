#!/bin/bash

# Deploy RBM-Pulse to GitHub Pages (FREE)
# This script builds and deploys your Flutter web app to GitHub Pages

set -e

echo "🌐 Deploying RBM-Pulse to GitHub Pages..."
echo ""

cd "$(dirname "$0")"

# Build web app
echo "🔨 Building web app..."
flutter build web --release

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Git not initialized. Please run:"
    echo "   git init"
    echo "   git remote add origin YOUR_GITHUB_REPO_URL"
    exit 1
fi

# Create gh-pages branch if it doesn't exist
if ! git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "📦 Creating gh-pages branch..."
    git checkout --orphan gh-pages
    git rm -rf .
else
    git checkout gh-pages
fi

# Copy build files
echo "📋 Copying build files..."
cp -r build/web/* .

# Commit and push
echo "📤 Pushing to GitHub..."
git add .
git commit -m "Deploy to GitHub Pages" || true
git push origin gh-pages --force

# Switch back to main branch
git checkout main 2>/dev/null || git checkout master 2>/dev/null || true

echo ""
echo "✅ Deployment complete!"
echo "🌐 Your app will be live at:"
echo "   https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/"
echo ""
echo "⚠️  Don't forget to enable GitHub Pages in repository settings!"

