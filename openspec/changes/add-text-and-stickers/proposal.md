# Change: Add Text and Sticker Capabilities to Canvas

## Why

InsGrids currently supports freeform image composition with photo adjustments, but users cannot add text labels, captions, or decorative elements to their compositions. This limits creative expression for social media posts, which commonly combine images with text overlays and decorative stickers. The existing emoji picker component exists but is not integrated into the canvas, leaving a gap in functionality.

Adding text and sticker support will enable users to:
- Add captions, titles, and labels directly on the canvas
- Decorate compositions with emoji, icons, and graphic stickers
- Create more engaging social media content without external editing tools
- Match the creative capabilities expected from modern photo composition apps

## What Changes

This change introduces **three new capabilities** to the freeform canvas:

### 1. Canvas Element Model (Foundation)
- **Unified Element System**: Create `CanvasElement` enum supporting: Image, Text, Sticker
- **Shared Transform Properties**: All elements share `id`, `position`, `scale`, `rotation`
- **Unified Gesture Handling**: Consistent drag, pinch, rotate interactions for all types
- **Z-Order Management**: Array-based layering with "Bring to Front" / "Send to Back" controls
- **Migration Support**: Backward compatibility with existing image-only auto-saved sessions

### 2. Text Elements (Independent Capability)
- **Text Creation and Editing**: Modal editor with multi-line input
- **Formatting Controls**: 
  - Font selection (7 system fonts: SF Pro, Helvetica, Georgia, etc.)
  - Size adjustment (12-72pt slider)
  - Color picker
  - Alignment options (left/center/right)
  - Background options (none/solid/semi-transparent)
- **Canvas Integration**:
  - Full gesture support (drag, scale, rotate, snap)
  - Double-tap to edit existing text
  - Long-press selection with action overlay (Edit, Delete, Z-order)
- **Persistence**: Auto-save and grid preset support
- **Export**: High-resolution CoreText rendering in tiles

### 3. Sticker Elements (Independent Capability)
- **Sticker Picker**: Modal sheet with two tabs
  - **Emoji Tab**: Reuses existing EmojiPickerView (8 categories, 20 emoji each)
  - **Stickers Tab**: SF Symbols library (6 categories, 15-20 symbols each) with search
- **Canvas Integration**:
  - Full gesture support (drag, scale, rotate, snap)
  - Long-press selection with action overlay (Delete, Z-order)
  - Scale constraints (0.3× to 4.0×) to prevent unusable sizes
- **Persistence**: Auto-save and grid preset support
- **Export**: High-resolution rendering (UIImage for SF Symbols, NSAttributedString for emoji)
- **Migration**: Replaces old emoji-per-cell system with free-form placement

### Cross-Capability Features
- **Localization**: English and Traditional Chinese translations for all UI
- **Undo/Redo**: All operations (add, edit, delete, transform, Z-order) integrate with existing stack
- **Unified Rendering**: Text and stickers render alongside images in correct Z-order during export

## Impact

- **Affected specs**: 
  - **NEW**: `canvas-elements` - Unified element model foundation
  - **NEW**: `text-elements` - Text creation, editing, and formatting
  - **NEW**: `sticker-elements` - Sticker placement and interaction
  
- **Affected code**:
  - `GridViewModel.swift` - Add `elements: [CanvasElement]` array, element management methods
  - `GridCanvasView.swift` - Render multiple element types, unified gestures
  - New model: `CanvasElement.swift` - Enum with Image/Text/Sticker cases
  - New views: `TextEditorView.swift`, `TextElementView.swift`
  - New views: `StickerPickerView.swift`, `StickerElementView.swift`, `IconPickerView.swift`
  - `EmojiPickerView.swift` - Integrate into sticker system
  - `GridEditingView.swift` - Add "Add Text" and "Add Sticker" toolbar buttons
  - `Localizable.strings` (en + zh-Hant) - Add UI strings for both capabilities
  - Auto-save: Extend `GridAutoSaveConfig` to serialize `CanvasElement` array
  - Export: Update `generateTiles()` to render text/stickers at high resolution

- **Memory considerations**: Text and stickers are lightweight compared to images, minimal impact expected
- **Backward compatibility**: Existing auto-saved grids migrate automatically to new element model
