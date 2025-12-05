#!/bin/bash

# Fix app_links plugin build.gradle compatibility issue
# This script patches the app_links plugin to use explicit compileSdk instead of flutter.compileSdkVersion

APP_LINKS_GRADLE="$HOME/.pub-cache/hosted/pub.dev/app_links-6.4.1/android/build.gradle"

if [ -f "$APP_LINKS_GRADLE" ]; then
    echo "🔧 Patching app_links plugin build.gradle..."
    
    # Backup original
    cp "$APP_LINKS_GRADLE" "$APP_LINKS_GRADLE.bak"
    
    # Replace flutter.compileSdkVersion with explicit value
    sed -i '' 's/compileSdk = flutter.compileSdkVersion/compileSdk = 34/g' "$APP_LINKS_GRADLE"
    
    echo "✅ Patch applied successfully!"
else
    echo "⚠️  app_links plugin not found at expected location"
    echo "   Looking for: $APP_LINKS_GRADLE"
    echo "   You may need to run 'flutter pub get' first"
fi

