#!/bin/bash

# Update Android app icon with RBM logo
# This script converts the SVG logo to Android icon sizes

set -e

cd "$(dirname "$0")"

SVG_LOGO="assets/logo/rbm-logo.svg"
ANDROID_RES="android/app/src/main/res"

if [ ! -f "$SVG_LOGO" ]; then
    echo "❌ Logo not found: $SVG_LOGO"
    exit 1
fi

echo "🎨 Creating Android app icons from RBM logo..."

# Android icon sizes (using array instead of associative array for zsh compatibility)
SIZES=("48:mipmap-mdpi" "72:mipmap-hdpi" "96:mipmap-xhdpi" "144:mipmap-xxhdpi" "192:mipmap-xxxhdpi")

# Generate icons
if command -v magick &> /dev/null; then
    for entry in "${SIZES[@]}"; do
        size="${entry%%:*}"
        dir="${entry##*:}"
        mkdir -p "$ANDROID_RES/$dir"
        echo "Creating $dir/ic_launcher.png (${size}x${size})..."
        magick -background none -resize "${size}x${size}" "$SVG_LOGO" "$ANDROID_RES/$dir/ic_launcher.png"
        # Also create round version
        magick -background none -resize "${size}x${size}" "$SVG_LOGO" "$ANDROID_RES/$dir/ic_launcher_round.png"
    done
elif command -v convert &> /dev/null; then
    for entry in "${SIZES[@]}"; do
        size="${entry%%:*}"
        dir="${entry##*:}"
        mkdir -p "$ANDROID_RES/$dir"
        echo "Creating $dir/ic_launcher.png (${size}x${size})..."
        convert -background none -resize "${size}x${size}" "$SVG_LOGO" "$ANDROID_RES/$dir/ic_launcher.png"
        convert -background none -resize "${size}x${size}" "$SVG_LOGO" "$ANDROID_RES/$dir/ic_launcher_round.png"
    done
else
    echo "⚠️  No image conversion tool found"
    echo "Please install ImageMagick: brew install imagemagick"
    exit 1
fi

echo "✅ Android app icons created successfully!"
echo "📁 Icons created in: android/app/src/main/res/mipmap-*/"

