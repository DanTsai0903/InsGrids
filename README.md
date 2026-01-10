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

## 🎯 Usage

1. **Select Photos**: Tap the "Select Photos" button to choose one or more photos from your library
2. **Adjust Settings**:
   - Use the slider to adjust image scale (how much of the frame the image fills)
   - Tap the aspect ratio button (4:5, 1:1, etc.) to change the output dimensions
   - Tap the border color button to choose or customize border color
3. **Save**: Tap "Save" to process and save all edited photos to your library

## 🏗 Architecture

```
InsGrids/
├── InstaBorderApp/
│   ├── Models/
│   │   ├── BorderConfiguration.swift   # Configuration model for border settings
│   │   └── ImageProcessor.swift        # Core image processing with 12MP limit
│   ├── ViewModels/
│   │   └── PhotoEditorViewModel.swift  # MVVM pattern, handles state & processing
│   ├── Views/
│   │   ├── ContentView.swift           # Landing screen with photo picker
│   │   ├── EditingView.swift           # Main editing interface
│   │   └── Components/                 # Reusable UI components
│   ├── Utilities/
│   │   └── ImageExporter.swift         # Photo library saving logic
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset/         # App icon
│       └── Logo.imageset/              # Launch screen logo
└── project.yml                         # XcodeGen configuration
```

## 🚀 Technical Highlights

- **Memory Management**: 
  - Thumbnail-based real-time preview (200px) for instant feedback
  - Full-resolution processing capped at 12MP (4000×3000) to prevent crashes
  - Serial processing with `autoreleasepool` to minimize memory footprint
  
- **Image Processing**:
  - Uses `UIGraphicsImageRenderer` for accurate centering and scaling
  - Pixel count limiting (width × height ≤ 12,000,000) instead of dimension limiting
  - Renderer scale set to 1.0 to avoid retina multiplication

- **Privacy**:
  - Uses `PhotosPicker` (iOS 14+) for restricted photo access
  - Requests `.addOnly` permission for saving, never full library access

## 📝 Permissions

The app requires the following permissions:

- **Photo Library (Limited)**: To let users select specific photos for editing
- **Photo Library Add**: To save processed photos back to the library

## 🎨 Design

- Dark theme with premium aesthetics
- Minimalist UI with floating controls
- Rounded, modern typography (SF Pro Rounded)
- Portrait-only orientation for focused editing experience

## 📄 License

This project is available for personal and educational use.

## 🙏 Acknowledgments

Built with Swift, SwiftUI, and lots of ☕️
