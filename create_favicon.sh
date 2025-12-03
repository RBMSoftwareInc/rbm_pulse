#!/bin/bash

# Create favicon and app icons from RBM logo SVG
# This script converts the SVG logo to PNG formats needed for web

set -e

cd "$(dirname "$0")"

SVG_LOGO="assets/logo/rbm-logo.svg"
WEB_DIR="web"

if [ ! -f "$SVG_LOGO" ]; then
    echo "❌ Logo not found: $SVG_LOGO"
    exit 1
fi

echo "🎨 Creating favicon and app icons from RBM logo..."

# Check for available tools
if command -v magick &> /dev/null; then
    # Use ImageMagick v7 - create square icons with logo centered
    echo "Using ImageMagick..."
    magick -size 32x32 xc:transparent \( "$SVG_LOGO" -resize 28x28 \) -gravity center -composite "$WEB_DIR/favicon.png"
    magick -size 192x192 xc:transparent \( "$SVG_LOGO" -resize 180x180 \) -gravity center -composite "$WEB_DIR/icons/Icon-192.png"
    magick -size 512x512 xc:transparent \( "$SVG_LOGO" -resize 480x480 \) -gravity center -composite "$WEB_DIR/icons/Icon-512.png"
    magick -size 192x192 xc:transparent \( "$SVG_LOGO" -resize 180x180 \) -gravity center -composite "$WEB_DIR/icons/Icon-maskable-192.png"
    magick -size 512x512 xc:transparent \( "$SVG_LOGO" -resize 480x480 \) -gravity center -composite "$WEB_DIR/icons/Icon-maskable-512.png"
elif command -v convert &> /dev/null; then
    # Use ImageMagick v6 - create square icons with logo centered
    echo "Using ImageMagick (v6)..."
    convert -size 32x32 xc:transparent \( "$SVG_LOGO" -resize 28x28 \) -gravity center -composite "$WEB_DIR/favicon.png"
    convert -size 192x192 xc:transparent \( "$SVG_LOGO" -resize 180x180 \) -gravity center -composite "$WEB_DIR/icons/Icon-192.png"
    convert -size 512x512 xc:transparent \( "$SVG_LOGO" -resize 480x480 \) -gravity center -composite "$WEB_DIR/icons/Icon-512.png"
    convert -size 192x192 xc:transparent \( "$SVG_LOGO" -resize 180x180 \) -gravity center -composite "$WEB_DIR/icons/Icon-maskable-192.png"
    convert -size 512x512 xc:transparent \( "$SVG_LOGO" -resize 480x480 \) -gravity center -composite "$WEB_DIR/icons/Icon-maskable-512.png"
else
    echo "⚠️  No image conversion tool found"
    echo "Please install ImageMagick: brew install imagemagick"
    echo "Or manually convert the SVG to PNG and place in web/ folder"
    exit 1
fi

echo "✅ Favicon and icons created successfully!"
echo "📁 Files created:"
echo "   - web/favicon.png (32x32)"
echo "   - web/icons/Icon-192.png (192x192)"
echo "   - web/icons/Icon-512.png (512x512)"
echo "   - web/icons/Icon-maskable-192.png (192x192)"
echo "   - web/icons/Icon-maskable-512.png (512x512)"
