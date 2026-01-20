# InsGrids

**Create Perfect Aspect Ratios for Your Photos** - A simple and elegant iOS app for adding customizable borders to your photos, perfect for Instagram and social media.

## 📢 What's New in v3.2.0

- **Custom Sticker Categories**: Browse 700+ stickers organized into intuitive themed collections
- **Sticker Import Automation**: Built-in tools for managing and importing custom sticker packs
- **Enhanced Memory Management**: Improved cache management prevents memory accumulation
- **iOS 26 Liquid Glass Design**: Modern, fluid UI that integrates seamlessly with iOS 26

See the full [Release Notes](https://github.com/DanTsai0903/InsGrids/releases/tag/v3.2.0).

## ✨ Features

- **Layout Templates**: Instagram Layout-style collages with predefined templates (2-4 photos). Customize borders, spacing, corner radius, aspect ratio, and background color.
- **Freeform Grid Layout**: Create Instagram aesthetics by splitting images across NxM grids (1x2, 2x3, 3x3, up to 6x6).
- **Text Tool**: Add customizable text overlays to your compositions with full font, size, color, and positioning control.
- **Sticker Library**: Extensive collection of 700+ stickers organized into themed categories (Animals, Nature, Food, Emojis, etc.) for creative expression.
- **Advanced Photo Editor**: Built-in editor with Lightroom-style adjustments (Exposure, Contrast, Highlights, Shadows, etc.) and professional filters.
- **Pro Crop Tool**: Advanced overlay-based cropping with **Locked Ratio Mode** (auto-locks 1:1, 4:5, 16:9) for precise composition.
- **Smart Gestures**: Drag to arrange, pinch to zoom/rotate, and double-tap to reset. Works for photos, text, and stickers.
- **Image Slicing**: Automatically splits your composition into perfect 4:5 aspect ratio tiles for Instagram posting.
- **iCloud Photos Support**: Seamlessly download and use photos stored in iCloud with visual progress indicator.
- **Proxy Image Workflow**: Edit smoothly with optimized thumbnails while preserving full original resolution for export.
- **Memory Optimized**: Handles high-resolution images (e.g., 48MP ProRAW) using advanced memory management and background tiled rendering.
- **Auto-Save & Restore**: Never lose your work - editing sessions are automatically saved and restored.
- **iPad Support**: Fully optimized for iPad with support for all interface orientations (Landscape & Portrait).
- **Privacy Focused**: No cloud uploads, all processing happens on-device.
- **Localization**: Supports English and Traditional Chinese (繁體中文).

## 📱 Requirements

- iOS 26.0+
- Xcode 26.0+
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

1. **Choose Layout**: Select "Freeform Grid" and set your desired columns/rows (e.g., 3 columns x 2 rows).
2. **Add & Arrange**:
   - Tap "+" to add photos.
   - **Text**: Add text overlays with customizable fonts, colors, and sizes.
   - **Stickers**: Browse 700+ stickers organized by categories - tap to add, drag to position.
   - **Move**: Drag photos, text, or stickers to any position.
   - **Transform**: Pinch to zoom or rotate images, text, and stickers. No scale limits.
   - **Edit**: Tap a photo -> "Edit" to adjust exposure, contrast, or apply filters.
   - **Crop**: Tap a photo -> "Crop" to use the locked-ratio crop tool.
   - **Layer**: Tap to bring an element to the front.
3. **Customize**:
   - Change background color using the color picker.
   - Adjust grid dimensions dynamically.
4. **Export**:
   - Tap "Export" to automatically slice the grid.
   - The app saves individual 4:5 tiles to your Photo Library in the correct posting order (1, 2, 3...).

## 🌍 Localization

The app supports the following languages:
- **English** (en)
- **Traditional Chinese** (zh-Hant) - 繁體中文

The app automatically follows your device's language settings.

## 🏗 Architecture

### Project Structure

```
InsGrids/
├── InstaBorderApp/                      # Main iOS application
│   ├── Models/                          # Data models and business logic
│   │   ├── BorderConfiguration.swift
│   │   ├── CanvasElement.swift         # Text & Sticker canvas elements
│   │   ├── CustomStickerCategory.swift # 700+ stickers organized by categories
│   │   ├── DraggableLine.swift
│   │   ├── FontFamily.swift
│   │   ├── IconLibrary.swift
│   │   ├── ImageProcessor.swift
│   │   ├── LayoutConfiguration.swift
│   │   ├── LayoutTemplate.swift        # Predefined and custom grid templates
│   │   ├── PhotoAdjustments.swift
│   │   ├── Preset.swift
│   │   ├── StickerCategory.swift
│   │   ├── StickerElement.swift
│   │   └── StickerManager.swift
│   ├── ViewModels/                      # MVVM view models
│   │   ├── GridViewModel.swift
│   │   ├── LayoutEditorViewModel.swift
│   │   ├── PhotoEditorViewModel.swift
│   │   └── PresetManager.swift
│   ├── Views/                           # SwiftUI views
│   │   ├── ContentView.swift           # Root view
│   │   ├── EditingView.swift
│   │   ├── GridEditingView.swift       # Main grid editing canvas
│   │   ├── LayoutEditorView.swift      # Layout template editor
│   │   ├── LayoutTemplateSelectView.swift
│   │   └── Components/                 # Reusable UI components
│   │       ├── AspectRatioSlider.swift
│   │       ├── ColorPickerView.swift
│   │       ├── CustomColorPaletteView.swift
│   │       ├── CustomGridInputSheet.swift
│   │       ├── DraggableLinesOverlay.swift
│   │       ├── EmojiPickerView.swift
│   │       ├── EyedropperOverlayView.swift
│   │       ├── FontPickerView.swift
│   │       ├── GridCanvasView.swift
│   │       ├── GridDimensionPicker.swift
│   │       ├── LayoutPhotoPickerView.swift
│   │       ├── PhotoEditorView.swift
│   │       ├── PresetsSheet.swift
│   │       ├── StickerPickerView.swift
│   │       ├── StickerView.swift
│   │       ├── TextEditorView.swift
│   │       └── TextElementView.swift
│   ├── Utilities/                       # Helper utilities
│   │   ├── ImageExporter.swift
│   │   └── PhotoEditorEngine.swift
│   ├── Styles/                          # Reusable styling components
│   ├── Resources/                       # App resources and assets
│   ├── en.lproj/                        # English localization
│   ├── zh-Hant.lproj/                   # Traditional Chinese localization
│   └── Assets.xcassets/
│       └── Stickers/                   # 700+ themed stickers
├── openspec/                            # OpenSpec workflow for structured development
│   ├── project.md                       # Project context and conventions
│   ├── specs/                           # Feature specifications
│   └── changes/                         # Individual change proposals
├── tools/                               # Development automation tools
│   └── sticker_importer/               # Python-based sticker import automation
├── agents/                              # AI agent workflows and outputs
├── .agent/workflows/                    # Development workflow definitions
├── project.yml                          # XcodeGen project configuration
├── generate_ipa.sh                      # IPA build script for deployment
└── import-stickers.sh                   # Sticker import wrapper script
```

### Architecture Pattern

The app follows a **MVVM (Model-View-ViewModel)** architecture:

- **Models**: Data structures and business logic (e.g., `LayoutTemplate`, `CustomStickerCategory`)
- **ViewModels**: Observable state management using Combine framework
- **Views**: SwiftUI declarative UI with reusable components

## 🚀 Technical Highlights

- **Proxy Image Workflow**: Implements a "Low-Res Edit, High-Res Export" architecture. 48MP images are cached to disk, and lightweight 1200px proxies are used for fluid UI performance.
- **Metal-Accelerated Editing**: The Photo Editor uses `CIContext` backed by Metal to render adjustments (tone curves, filters, blending) in real-time at 60fps.
- **Tiled Rendering**: Exports are processed in background threads using tiled rendering. High-res assets are dynamically loaded and released for each tile to strictly control memory usage (OOM prevention).
- **Auto-Save System**: Robust state persistence using file system storage for images and UserDefaults for metadata, surviving app termination.
- **Safe Layout**: Advanced geometry calculations for crop and canvas management.

## 🔧 Development Workflow

This project uses a structured development approach with **OpenSpec** workflow for managing changes:

### OpenSpec Process

1. **Proposal Phase** (`/openspec-proposal`): Create a structured change proposal with goals, requirements, and design considerations
2. **Design Phase**: Document technical approach and implementation details in `design.md`
3. **Implementation Phase** (`/openspec-apply`): Execute changes while keeping tasks synchronized
4. **Archive Phase** (`/openspec-archive`): Document completed changes and update project specs

### Development Tools

- **XcodeGen**: Project file generation from declarative `project.yml` configuration
- **Sticker Importer**: Python-based automation tool for bulk sticker asset management
  - Located in `tools/sticker_importer/`
  - Uses `uv` for Python dependency management
  - Supports pHash-based deduplication
- **IPA Generator**: Shell script (`generate_ipa.sh`) for creating deployable app packages
- **AI Agents**: Workflow automation agents in `agents/` directory

### Testing

- **Framework**: pytest (for Python tools)
- **iOS Testing**: Manual verification and planned XCTest integration
- Focus areas: Image processing, memory management, localization

## 📝 Permissions

- **Photo Library (Limited)**: To select photos for editing
- **Photo Library Add**: To save processed photos

## 📄 License

This project is available for personal and educational use.

## 🙏 Acknowledgments

Built with Swift, SwiftUI, and lots of ☕️
