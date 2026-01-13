# Release Notes - InsGrids v2.1.0

This update introduces the new Layout feature and improved iCloud support.

## 🚀 New Features

### 📐 Layout Templates
- **Instagram Layout-Style Collages**: Create beautiful photo collages with predefined templates supporting 2-4 photos.
- **6 Template Styles**: Choose from grid, column, and row-based layouts.
- **Full Customization**: Adjust outer border, inner spacing, corner radius, aspect ratio (1:1, 4:5, 16:9, 9:16), and background color.
- **Photo Manipulation**: Pan and zoom individual photos within their slots.
- **Edit & Crop**: Long-press any photo to access Edit (adjustments/filters) or Crop tools.
- **Undo & Reset**: Full undo stack and reset to defaults functionality.

### ☁️ iCloud Photos Support
- **Seamless iCloud Downloads**: Photos stored in iCloud are automatically downloaded when selected.
- **Visual Progress Indicator**: "Downloading from iCloud..." overlay shown during photo downloads across the entire app.

## 🐛 Bug Fixes

- **Fixed**: Photos not appearing after re-adding to deleted Layout slots (race condition with PhotosPicker).
- **Fixed**: Proper state reset when photo selection fails or is cancelled.

## 📱 Requirements
- iOS 26.0+
- Xcode 26.0+
