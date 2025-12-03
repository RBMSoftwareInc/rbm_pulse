# Android APK Build & Installation Guide

This guide will help you build an Android APK for RBM-Pulse and install it on your mobile device using a QR code.

## Prerequisites

1. **Flutter SDK** installed and configured
   ```bash
   flutter doctor
   ```
   Make sure all required components are installed.

2. **Android Studio** or Android SDK tools installed

3. **Python 3** (optional, for QR code generation)

## Method 1: Quick Build Script

### Step 1: Build the APK

Run the build script:

```bash
cd rbm_pulse
chmod +x build_android.sh
./build_android.sh
```

The APK will be created at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 2: Upload APK to a Web Server

You need to make the APK accessible via a URL. Options:

**Option A: Use a File Sharing Service**
- Upload to [Google Drive](https://drive.google.com), [Dropbox](https://dropbox.com), or [WeTransfer](https://wetransfer.com)
- Get a direct download link (make sure it's publicly accessible)

**Option B: Use a Simple HTTP Server**
```bash
# Install a simple HTTP server
python3 -m pip install http.server

# Navigate to the build directory
cd build/app/outputs/flutter-apk

# Start server (replace YOUR_IP with your computer's IP)
python3 -m http.server 8000

# Your APK URL will be: http://YOUR_IP:8000/app-release.apk
```

**Option C: Use GitHub Releases**
- Create a GitHub release and upload the APK
- Use the release asset URL

### Step 3: Generate QR Code

**Using Python script:**
```bash
# Install qrcode library
python3 -m pip install qrcode[pil]

# Generate QR code
python3 generate_qr.py "YOUR_APK_URL"
```

**Using Online Tools:**
1. Go to [QR Code Generator](https://www.qr-code-generator.com/)
2. Select "URL" type
3. Paste your APK download URL
4. Download the QR code image

**Using Command Line (if you have `qrcode` installed):**
```bash
python3 generate_qr.py "https://your-server.com/app-release.apk"
```

### Step 4: Install on Android Device

1. **Enable Unknown Sources:**
   - Go to Settings → Security → Enable "Install from Unknown Sources"
   - Or Settings → Apps → Special Access → Install Unknown Apps

2. **Scan QR Code:**
   - Open your camera app or a QR code scanner
   - Scan the generated QR code
   - Tap the notification to download

3. **Install APK:**
   - Open the downloaded APK file
   - Tap "Install"
   - Wait for installation to complete

## Method 2: Manual Build

### Step 1: Clean and Get Dependencies

```bash
cd rbm_pulse
flutter clean
flutter pub get
```

### Step 2: Build Release APK

```bash
flutter build apk --release
```

### Step 3: Find Your APK

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Method 3: Direct USB Installation

If your device is connected via USB:

```bash
# Build and install directly
flutter install --release

# Or use adb
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting

### Build Errors

**Error: "Gradle build failed"**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

**Error: "SDK not found"**
- Make sure Android SDK is installed
- Set `ANDROID_HOME` environment variable
- Run `flutter doctor` to check configuration

### Installation Errors

**"App not installed" error:**
- Make sure "Install from Unknown Sources" is enabled
- Check if you have enough storage space
- Try uninstalling any previous version first

**"Parse Error":**
- The APK might be corrupted
- Rebuild the APK
- Make sure the download completed successfully

## Alternative: Using Firebase App Distribution

For easier distribution to multiple devices:

1. Create a Firebase project
2. Enable App Distribution
3. Upload APK to Firebase
4. Share the download link or invite testers

## Security Note

⚠️ **Important:** The current build uses debug signing. For production:

1. Create a keystore:
```bash
keytool -genkey -v -keystore ~/rbm-pulse-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias rbm-pulse
```

2. Update `android/app/build.gradle` with signing config

3. Create `android/key.properties`:
```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=rbm-pulse
storeFile=/path/to/rbm-pulse-key.jks
```

## File Size Optimization

To reduce APK size, you can build split APKs:

```bash
flutter build apk --split-per-abi
```

This creates separate APKs for different architectures (arm64-v8a, armeabi-v7a, x86_64).

## Quick Reference

| Command | Description |
|---------|-------------|
| `flutter build apk --release` | Build release APK |
| `flutter build apk --split-per-abi` | Build split APKs by architecture |
| `flutter install --release` | Build and install via USB |
| `adb install app-release.apk` | Install APK via ADB |

## Next Steps

After installation:
1. Open the app on your device
2. Configure your Supabase credentials (if needed)
3. Test all features
4. Report any issues

---

**Need Help?** Check Flutter documentation: https://flutter.dev/docs/deployment/android

