# Release Notes - Proxy Image Workflow & Grid Editing v2.0.0

This major update introduces a complete architectural overhaul for image handling ("Proxy Workflow") to solve memory crashes with high-resolution photos, along with powerful new editing features.

## 🚀 New Features

### 🖼️ Proxy Image Workflow (Performance)
- **Edit Small, Export Big**: We now use lightweight cached thumbnails (1200px) for a fluid editing experience, while preserving the full 48MP+ original data for the final export.
- **Zero OOM Crashes**: Drastically reduced memory footprint during editing, preventing crashes even when loading multiple ProRAW images.

### 🧩 Tiled Background Export
- **12MP High-Res Output**: New export engine renders the grid in "tiles" (chunks) in the background.
- **Dynamic Asset Swapping**: The exporter dynamically loads high-res originals only when rendering a specific tile and releases them immediately, ensuring high quality without memory spikes.

### ✂️ Advanced In-Canvas Cropping
- **Non-Destructive Crop**: Crop individual images within the grid.
- **Aspect Ratio Presets**: Rapidly crop to standard ratios like 1:1, 4:5, 16:9, etc.
- **High-Fidelity**: Cropping now loads the source image from disk to verify details before applying.

### 📐 Freeform Grid Layout
- **Customizable Grids**: Support for 2x2, 2x3, 3x3 layouts and more.
- **Auto-Layout**: Canvas automatically adjusts aspect ratio based on grid dimensions.

## 🛠 Improvements & Fixes
- **Auto-Save 2.0**: Migrated image storage from `UserDefaults` (which caused crashes) to the file system. Your work is now safely saved even if the app quits.
- **iPad Support**: Optimized layout and orientation settings for iPad multitasking.
- **Gesture Refinement**: Improved pinch-to-zoom and drag mechanics.

## ⚠️ Known Issues
- **Crop View Crash**: In rare cases, tapping "Crop" immediately after adding a large photo may cause a crash. **Workaround**: Move or zoom the photo slightly before cropping.

## 📱 Requirements
- iOS 26.0+
- Xcode 26.0+
