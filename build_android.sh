#!/bin/bash

# Build Android APK for RBM-Pulse
# This script builds a release APK that can be installed on Android devices

set -e

echo "🚀 Building RBM-Pulse Android APK..."
echo ""

# Navigate to project directory
cd "$(dirname "$0")"

# Fix app_links plugin compatibility issue
if [ -f "fix_app_links.sh" ]; then
    echo "🔧 Fixing app_links plugin compatibility..."
    ./fix_app_links.sh
fi

# Note: If you encounter "Must provide Flutter source directory" error,
# this is a known issue with Flutter 3.24.3 and the new Gradle plugin.
# Try: flutter downgrade or update Flutter to latest version

# Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Fix app_links again after pub get (in case it was reinstalled)
if [ -f "fix_app_links.sh" ]; then
    ./fix_app_links.sh
fi

# Build APK
echo "🔨 Building release APK..."
flutter build apk --release

# APK location
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    # Get file size
    FILE_SIZE=$(du -h "$APK_PATH" | cut -f1)
    
    echo ""
    echo "✅ Build successful!"
    echo "📱 APK Location: $APK_PATH"
    echo "📊 File Size: $FILE_SIZE"
    echo ""
    echo "📋 Next steps:"
    echo "1. Copy the APK to a web server or use a file sharing service"
    echo "2. Generate a QR code with the APK download URL"
    echo "3. Scan the QR code with your Android device"
    echo "4. Install the APK (enable 'Install from Unknown Sources' if needed)"
    echo ""
    echo "💡 To generate QR code, you can use:"
    echo "   - Online: https://www.qr-code-generator.com/"
    echo "   - Or run: python3 -m pip install qrcode && python3 generate_qr.py"
else
    echo "❌ Build failed! APK not found."
    exit 1
fi

