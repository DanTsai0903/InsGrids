#!/bin/bash

# 腳本：生成給 AltStore 使用的 .ipa 檔案

echo "🚀 開始建置 InsGrids..."

# 1. 清理舊的編譯檔案
rm -rf build
rm -rf Payload
rm -f InsGrids.ipa

# 2. 使用 XcodeBuild 編譯 (不簽名)
xcodebuild -project InsGrids.xcodeproj \
  -target InsGrids \
  -configuration Release \
  -sdk iphoneos \
  SYMROOT="$(pwd)/build" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# 檢查編譯是否成功
if [ $? -ne 0 ]; then
    echo "❌ 編譯失敗"
    exit 1
fi

echo "📦 正在打包 IPA..."

# 3. 建立 Payload 資料夾結構
mkdir Payload

# 4. 複製 App 到 Payload
cp -r build/Release-iphoneos/InsGrids.app Payload/

# 5. 壓縮成 .ipa
zip -r -q InsGrids.ipa Payload

# 6. 清理暫存檔
rm -rf build
rm -rf Payload

echo "✅ 完成！已產生 InsGrids.ipa"
open .
