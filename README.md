# InsGrids

**Create Perfect Aspect Ratios for Your Photos** - A simple and elegant iOS app for adding customizable borders to your photos, perfect for Instagram and social media.

## ✨ Features

- **Freeform Canvas**: Arrange photos freely in a customizable grid (2x2, 3x3, etc.)
- **Advanced Cropping**: Crop images directly on the canvas with aspect ratio presets (1:1, 4:5, 16:9, etc.)
- **Smart Gestures**: Drag to move, pinch to zoom/rotate, and intuitive delete interactions
- **Proxy Image Workflow**: Edit smoothly with optimized thumbnails while preserving full original resolution
- **Tiled Export**: Export high-resolution grids (up to 12MP per tile) using background tiled rendering
- **Auto-Save & Restore**: Your work is automatically saved and can be restored if the app is closed
- **Undo/Redo**: Full undo history support for all canvas operations
- **Memory Optimized**: Handles high-resolution images (e.g., 48MP ProRAW) using advanced memory management
- **Privacy Focused**: Uses iOS Photo Picker with minimal permissions
- **Presets**: Save your favorite aspect ratio, scale, and color settings for quick access
- **Localization**: Supports English and Traditional Chinese (繁體中文)

## 📱 Requirements

- iOS 17.0+
- Xcode 15.0+
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
- iPhone with iOS 16.0+
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

1. **Select Photos**: Tap the "+" button freely add photos to your grid
2. **Arrange**: 
   - **Move**: Drag photos to rearrange
   - **Zoom/Rotate**: Pinch with two fingers
   - **Crop**: Tap a photo -> Crop icon
   - **Delete**: Drag photo to the bottom trash can or long press
3. **Customize Grid**:
   - Tap the grid button (e.g. "2x2") to change layout columns/rows
   - Tap the color circle to change background color
4. **Export**: Tap "Export" to save the high-resolution grid tiles to your library

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
│   │   ├── CanvasImage.swift
│   │   ├── GridAutoSaveConfig.swift
│   │   └── ImageProcessor.swift
│   ├── ViewModels/
│   │   └── GridViewModel.swift
│   ├── Views/
│   │   ├── GridEditingView.swift
│   │   ├── Components/
│   │   │   ├── FreeformCanvasView.swift
│   │   │   ├── ImageCropView.swift
│   │   │   └── GridCanvasView.swift
│   ├── Utilities/
│   │   └── ImageExporter.swift
│   ├── en.lproj/
│   ├── zh-Hant.lproj/
│   └── Assets.xcassets/
├── project.yml
└── generate_ipa.sh
```

## 🚀 Technical Highlights

- **Proxy Image Workflow**: Implements a "Low-Res Edit, High-Res Export" architecture. 48MP images are cached to disk, and lightweight 1200px proxies are used for fluid UI performance.
- **Tiled Rendering**: Exports are processed in background threads using tiled rendering. High-res assets are dynamically loaded and released for each tile to strictly control memory usage (OOM prevention).
- **Auto-Save System**: Robust state persistence using file system storage for images and UserDefaults for metadata, surviving app termination.
- **Safe Layout**: Advanced geometry calculations for crop and canvas management.

## 📝 Permissions

- **Photo Library (Limited)**: To select photos for editing
- **Photo Library Add**: To save processed photos

## 📄 License

This project is available for personal and educational use.

## 🙏 Acknowledgments

Built with Swift, SwiftUI, and lots of ☕️
