# InsGrids

**Create Perfect Aspect Ratios for Your Photos** - A simple and elegant iOS app for adding customizable borders to your photos, perfect for Instagram and social media.

## ✨ Features

- **Customizable Borders**: Add white, black, or custom-colored borders to your photos
- **Multiple Aspect Ratios**: Support for 1:1, 4:5, 16:9, and 9:16 aspect ratios
- **Adjustable Image Scale**: Resize your photo within the border (30% - 100%)
- **Batch Processing**: Select and edit multiple photos at once
- **Real-time Preview**: See changes instantly with optimized thumbnail rendering
- **Memory Optimized**: Carefully designed to handle high-resolution photos without crashes
- **Privacy Focused**: Uses iOS Photo Picker with minimal permissions
- **Presets**: Save your favorite aspect ratio, scale, and color settings for quick access
- **Localization**: Supports English and Traditional Chinese (繁體中文)

## 📱 Requirements

- iOS 26.0+
- Xcode 26.2+
- Swift 5.9+

## 🛠 Installation

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project file.

### Step 1: Install XcodeGen

```bash
brew install xcodegen
```

### Step 2: Clone the Repository

```bash
git clone https://github.com/DanTsai0903/InsGrids.git
cd InsGrids
```

### Step 3: Generate Xcode Project

```bash
xcodegen generate
```

### Step 4: Open in Xcode

```bash
open InsGrids.xcodeproj
```

### Step 5: Build and Run

Press `Cmd + R` to build and run on your device or simulator.

## 📲 Installing with AltStore (Free, No Developer Account Required)

If you don't have an Apple Developer account ($99/year), you can use [AltStore](https://altstore.io/) to install the app on your iPhone for free.

### Prerequisites

- A Mac or Windows PC
- iPhone with iOS 12.2+
- Same WiFi network for phone and computer

### Step 1: Generate IPA File

Run the included script to build an unsigned IPA:

```bash
./generate_ipa.sh
```

This will create `InsGrids.ipa` in the project folder.

### Step 2: Install AltServer on Your Computer

1. Download [AltServer](https://altstore.io/) for Mac or Windows
2. Install and run AltServer (it appears in the menu bar)

### Step 3: Install AltStore on Your iPhone

1. Connect iPhone to computer via USB
2. Click AltServer icon → Install AltStore → Select your iPhone
3. Enter your Apple ID (used for free signing)
4. AltStore app will appear on your iPhone
5. Go to Settings → General → VPN & Device Management → Trust your Apple ID

### Step 4: Install InsGrids

1. Transfer `InsGrids.ipa` to your iPhone (via iCloud Drive, AirDrop, or any cloud service)
2. Open the Files app on iPhone, locate the .ipa file
3. Tap and hold → Share → AltStore
4. Wait for installation to complete

### Keeping the App Active

Free accounts have a 7-day expiration. To keep the app working:
- Keep AltServer running on your computer
- Ensure iPhone and computer are on the same WiFi
- AltStore will automatically refresh the app in the background

## 🎯 Usage

1. **Select Photos**: Tap the "Select Photos" button to choose one or more photos from your library
2. **Adjust Settings**:
   - Use the slider to adjust image scale (how much of the frame the image fills)
   - Tap the aspect ratio button (4:5, 1:1, etc.) to change the output dimensions
   - Tap the border color button to choose or customize border color
3. **Use Presets** (Optional):
   - Tap the **Presets** button (bookmark icon) in the bottom toolbar to save your current settings or apply a previously saved preset.
4. **Save**: Tap "Save" to process and save all edited photos to your library

## 🌍 Localization

The app supports the following languages:
- **English** (en)
- **Traditional Chinese** (zh-Hant) - 繁體中文

The app automatically follows your device's language settings.

## 🏗 Architecture

```
InsGrids/
├── InstaBorderApp/
│   ├── Models/
│   │   ├── BorderConfiguration.swift
│   │   └── ImageProcessor.swift
│   ├── ViewModels/
│   │   └── PhotoEditorViewModel.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── EditingView.swift
│   │   └── Components/
│   ├── Utilities/
│   │   └── ImageExporter.swift
│   ├── en.lproj/
│   ├── zh-Hant.lproj/
│   └── Assets.xcassets/
├── project.yml
└── generate_ipa.sh
```

## 🚀 Technical Highlights

- **Memory Management**: Thumbnail-based preview, 12MP output limit, serial processing with autoreleasepool
- **Image Processing**: UIGraphicsImageRenderer with pixel count limiting
- **Privacy**: PhotosPicker with `.addOnly` permission

## 📝 Permissions

- **Photo Library (Limited)**: To select photos for editing
- **Photo Library Add**: To save processed photos

## 📄 License

This project is available for personal and educational use.

## 🙏 Acknowledgments

Built with Swift, SwiftUI, and lots of ☕️
