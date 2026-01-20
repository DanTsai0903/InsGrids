#!/bin/bash

# Script: Generate .ipa file for AltStore usage

echo "🚀 Starting InsGrids build..."

# 1. Clean up old build files
rm -rf build
rm -rf Payload
rm -f InsGrids.ipa

# 2. Build using XcodeBuild (unsigned)
xcodebuild -project InsGrids.xcodeproj \
  -target InsGrids \
  -configuration Release \
  -sdk iphoneos \
  SYMROOT="$(pwd)/build" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "📦 Packaging IPA..."

# 3. Create Payload directory structure
mkdir Payload

# 4. Copy App to Payload
cp -r build/Release-iphoneos/InsGrids.app Payload/

# 5. Zip into .ipa
zip -r -q InsGrids.ipa Payload

# 6. Cleanup temporary files
rm -rf build
rm -rf Payload

echo "✅ Done! InsGrids.ipa generated"
open .
