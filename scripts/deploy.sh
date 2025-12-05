#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="rbm_pulse"
BUILD_DIR="build/web"
BASE_HREF="${BASE_HREF:-/}"

echo -e "${GREEN}🚀 RBM-Pulse GitHub Pages Deployment Script${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if we're in the right directory
if [ ! -d "$APP_DIR" ]; then
    echo -e "${RED}❌ Directory '$APP_DIR' not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Check for required environment variables
if [ -z "$SUPABASE_URL" ]; then
    echo -e "${YELLOW}⚠️  SUPABASE_URL not set${NC}"
    echo "Please set it: export SUPABASE_URL='https://your-project.supabase.co'"
    read -p "Enter SUPABASE_URL: " SUPABASE_URL
fi

if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${YELLOW}⚠️  SUPABASE_ANON_KEY not set${NC}"
    echo "Please set it: export SUPABASE_ANON_KEY='your-anon-key'"
    read -p "Enter SUPABASE_ANON_KEY: " SUPABASE_ANON_KEY
fi

# Validate environment variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}❌ Both SUPABASE_URL and SUPABASE_ANON_KEY are required${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Environment variables configured${NC}"
echo ""

# Navigate to app directory
cd "$APP_DIR"

# Clean previous build
echo -e "${YELLOW}🧹 Cleaning previous build...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Build for web
echo -e "${YELLOW}🔨 Building Flutter web app...${NC}"
echo "Using BASE_HREF: $BASE_HREF"
echo ""

flutter build web --release \
    --base-href "$BASE_HREF" \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

# Check if build was successful
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}❌ Build failed - $BUILD_DIR directory not found${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo -e "${GREEN}📁 Build output: $BUILD_DIR${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. For local testing:"
echo "   cd $BUILD_DIR && python3 -m http.server 8000"
echo ""
echo "2. For GitHub Pages deployment:"
echo "   - Push to main/master branch (GitHub Actions will auto-deploy)"
echo "   - Or manually deploy the $BUILD_DIR folder to GitHub Pages"
echo ""
echo -e "${GREEN}✨ Done!${NC}"
