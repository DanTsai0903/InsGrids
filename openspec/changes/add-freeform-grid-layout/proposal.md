# Change: Add Freeform Grid Layout for Multi-Post Instagram Compositions

## Why

Currently, InsGrids only supports adding borders to individual photos. However, a popular Instagram aesthetic involves splitting a single image across multiple posts (1x2 to 3x3 grids) to create a cohesive feed layout, as shown in professional accounts like BLACKPINK Official.

This feature will allow users to:
- Create visually striking Instagram feeds with large-scale compositions
- Split one or multiple images across a configurable grid (1x2 up to 3x3)
- Arrange and position images freely within the grid
- Export all grid tiles in the correct posting order

## What Changes

### New Capabilities
- **Grid Layout Selection**: Users can choose arbitrary grid dimensions (NxM, e.g., 1x2, 2x3, 3x4, etc.)
- **Image Slicing Engine**: New processor to split images into equal tiles with proper Instagram 4:5 portrait aspect ratio
- **Freeform Canvas**: Drag-and-drop interface for positioning multiple images within the grid
- **Enhanced Crop Functionality**: Crop images with locked aspect ratios (1:1, 4:5) and stable overlay-based UI
- **Grid Preview**: Real-time visualization of how the final Instagram feed will look
- **Sequential Export**: Save all grid tiles in the correct order (left-to-right, top-to-bottom) for easy posting
- **Emoji Support**: Add emoji overlays to individual grid cells for creative expression
- **Auto-Save**: Automatically save grid editing sessions to resume later
- ~~**Grid Presets**~~: (Aborted - not needed for freeform mode)

### User Interface Changes
- New "Freeform Grid" mode accessible from main ContentView
- Custom grid dimension picker (rows and columns input, common presets)
- Canvas for dragging/resizing images within grid cells
- Grid overlay showing post boundaries
- Improved Crop UI with locked ratio mode and lock/unlock toggle
- Emoji picker for adding emoji to cells
- Background color picker for empty cells
- Export button that saves numbered tiles (e.g., `grid_1.jpg`, `grid_2.jpg`, ...)

### Technical Changes
- New `GridLayout` model to store grid configuration (rows, columns, cell assignments, emoji data)
- Extended `GridLayout` with `Codable` for auto-save
- New `GridProcessor` to handle image slicing and tile generation with 4:5 ratio
- New `GridCanvasView` for the freeform editing interface
- New `GridViewModel` to manage grid state, image placements, and auto-save
- New `EmojiPickerView` component for emoji selection
- Extension to existing `ImageExporter` for batch tile export
- Auto-save mechanism using `UserDefaults`

## Impact

### Affected Specs
- **New**: `freeform-grid` - Complete grid layout and slicing capability

### Affected Code
- **New Files**:
  - `Models/GridLayout.swift` - Grid configuration model with Codable
  - `Models/GridCell.swift` - Cell model with emoji support
  - `Models/GridProcessor.swift` - Image slicing logic (4:5 tiles)
  - `ViewModels/GridViewModel.swift` - Grid state management with auto-save
  - `Views/GridCanvasView.swift` - Main grid editing interface
  - `Views/Components/GridDimensionPicker.swift` - Custom NxM dimension selector
  - `Views/Components/EmojiPickerView.swift` - Emoji selection interface
  
- **Modified Files**:
  - `Views/ContentView.swift` - Add navigation to Grid mode
  - `ViewModels/PresetManager.swift` - Extend to support grid presets
  - `Models/Preset.swift` - Update to include grid layouts
  - `Utilities/ImageExporter.swift` - Add batch export with sequential naming
  - `en.lproj/Localizable.strings` - New localization strings
  - `zh-Hant.lproj/Localizable.strings` - New Chinese translations

### User Experience Impact
- Adds a new major feature mode (alongside current single-photo border mode)
- Requires users to learn a new canvas-based interface
- Emoji feature adds creative expression options
- Auto-save prevents work loss if app closes unexpectedly
- Grid presets enable quick reuse of common layouts
- Arbitrary grid sizes provide maximum flexibility
- May increase memory usage when processing large grids (mitigated by existing 12MP limits and 4:5 ratio)
- Provides significant value for Instagram power users and content creators

### Compatibility
- **No Breaking Changes**: Existing single-photo border workflow remains unchanged
- Maintains all existing memory management patterns (autoreleasepool, serial processing)
- **Extends existing preset system**: Grid presets integrate seamlessly with border presets
- Auto-save data stored separately from border mode settings
