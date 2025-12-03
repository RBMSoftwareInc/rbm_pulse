#!/bin/bash

# Build Flutter web app with environment variables from .env file
# This script reads .env and builds with --dart-define flags

set -e

cd "$(dirname "$0")"

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env file not found!"
    echo ""
    echo "Please create a .env file with:"
    echo "  SUPABASE_URL=https://your-project.supabase.co"
    echo "  SUPABASE_ANON_KEY=your_anon_key"
    echo ""
    echo "Or run: cp env.example .env"
    echo "Then edit .env with your Supabase credentials"
    exit 1
fi

echo "📖 Reading environment variables from .env..."

# Read variables from .env file
SUPABASE_URL=$(grep "^SUPABASE_URL=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'" | xargs)
SUPABASE_ANON_KEY=$(grep "^SUPABASE_ANON_KEY=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'" | xargs)

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file"
    echo ""
    echo "Your .env file should contain:"
    echo "  SUPABASE_URL=https://your-project.supabase.co"
    echo "  SUPABASE_ANON_KEY=your_anon_key"
    exit 1
fi

echo "✅ Found Supabase credentials"
echo "🔨 Building web app with environment variables..."

# Build with dart-define flags
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo ""
echo "✅ Build complete!"
echo "📁 Web files are in: build/web/"
echo ""
echo "🚀 To deploy:"
echo "   1. Drag build/web folder to https://app.netlify.com/drop"
echo "   2. Or run: ./deploy_netlify.sh"

