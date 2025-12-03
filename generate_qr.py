#!/usr/bin/env python3
"""
Generate QR code for Android APK download
Usage: python3 generate_qr.py [APK_URL]
"""

import sys
import qrcode
from pathlib import Path

def generate_qr_code(url, output_file='apk_qr_code.png'):
    """Generate QR code for the given URL"""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(url)
    qr.make(fit=True)
    
    img = qr.make_image(fill_color="black", back_color="white")
    img.save(output_file)
    print(f"✅ QR code generated: {output_file}")
    print(f"📱 URL: {url}")
    return output_file

if __name__ == "__main__":
    if len(sys.argv) > 1:
        url = sys.argv[1]
    else:
        # Default: ask for URL
        url = input("Enter the APK download URL: ").strip()
        if not url:
            print("❌ URL is required!")
            sys.exit(1)
    
    generate_qr_code(url)

