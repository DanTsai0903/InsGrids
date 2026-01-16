# Implementation Plan: Add Text and Sticker Capabilities

## Summary

This change extends the InsGrids freeform canvas to support text and sticker elements alongside existing images. The implementation introduces a unified `CanvasElement` enum model that wraps three element types (Image, Text, Sticker) with shared transform properties. This maintains the existing gesture system while adding new UI components for text editing and sticker selection.

## User Review Required

> [!IMPORTANT]
> **Migration Path**: Existing auto-saved sessions will be automatically migrated to the new `CanvasElement` model on first restore. Users won't lose data, but old app versions won't be able to read new sessions after migration.

> [!NOTE]
> **Text Editing Pattern**: Double-tap is used to edit existing text elements (not single tap) to avoid conflict with drag gestures. This follows iOS conventions (Notes, Pages).

> [!NOTE]
> **Z-Order Controls**: "Bring to Front" and "Send to Back" buttons will be added to **all element types** (images, text, stickers) for consistency. This extends the existing image action overlay.

## Proposed Changes

### Core Models

#### [NEW] [CanvasElement.swift](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/Models/CanvasElement.swift)

New unified element model supporting three types:
- **Enum structure**: `CanvasElement` with cases `.image(ImageElement)`, `.text(TextElement)`, `.sticker(StickerElement)`
- **Shared properties**: `id`, `position`, `scale`, `rotation` exposed via computed properties
- **Element-specific data**:
  - `TextElement`: `text`, `font`, `fontSize`, `color`, `alignment`, `backgroundColor`, `backgroundOpacity`
  - `StickerElement`: `type` (emoji/sfSymbol), `content`, `color` (SF Symbols only), `size`
  - `ImageElement`: wraps existing `CanvasImage` data (image, adjustments, originalImageId)
- **Codable conformance**: All types support persistence

---

### ViewModel Layer

#### [MODIFY] [GridViewModel.swift](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/ViewModels/GridViewModel.swift)

**Element Management:**
- Add `@Published var elements: [CanvasElement]` alongside existing `images: [CanvasImage]` (temporary dual-model)
- New methods: `addTextElement()`, `addStickerElement()`, `updateElement()`, `deleteElement()`
- Extend undo/redo to capture entire `elements` array state

**Auto-Save Extension:**
- Update `GridAutoSaveConfig` struct to include `elements: [CanvasElement]` field
- Modify `saveState()` and `restoreSession()` to serialize/deserialize new model
- Add migration: detect old format, convert `CanvasImage` → `CanvasElement.image(ImageElement)`

**Export Pipeline:**
- Extend `generateTiles()` to iterate through `elements` array (not just images)
- Add helper methods:
  - `renderTextElement(on:element:in:scale:)` - Uses CoreText with NSAttributedString
  - `renderStickerElement(on:element:in:scale:)` - Uses UIImage(systemName:) for icons, NSAttributedString for emoji
- Single-pass rendering in array order to preserve Z-order

---

### View Components

#### [NEW] [TextEditorView.swift](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/Views/Components/TextEditorView.swift)

Modal sheet for creating/editing text elements:
- **Input**: TextEditor for multi-line text
- **Formatting controls**: Font picker (7 system fonts), size slider (12-72pt), color picker, alignment buttons (L/C/R)
- **Background options**: Segmented picker (None/Solid/Semi-transparent) with color picker
- **Live preview**: Shows formatted text below controls
- Binding to `TextElement` for two-way editing

#### [NEW] [StickerPickerView.swift](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/Views/Components/StickerPickerView.swift)

Modal sheet with TabView:
- **Emoji tab**: Reuses existing `EmojiPickerView` (8 categories, 20 emoji each)
- **Stickers tab**: New `IconPickerView` with 6 SF Symbol categories (15-20 symbols each):
  - Arrows, Shapes, Communication, Weather, Nature, Objects
- **Search**: TextField to filter SF Symbols by name
- **Callback**: `onSelect: (StickerElement) -> Void` to add sticker to canvas

#### [NEW] [TextElementView.swift](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/Views/Components/TextElementView.swift)

Renders text element on canvas:
- Text view with font, size, color, alignment from `TextElement`
- Optional background rectangle with opacity
- Apply `.position()`, `.scaleEffect()`, `.rotationEffect()` transforms
- Gesture support via shared handlers

#### [NEW] [StickerElementView.swift](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/Views/Components/StickerElementView.swift)

Renders sticker element on canvas:
- For emoji: Text view with emoji character
- For SF Symbol: Image(systemName:) with color tint
- Apply transform modifiers consistently

---

#### [MODIFY] [GridCanvasView.swift](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/Views/Components/GridCanvasView.swift)

**Element Rendering:**
- Replace `ForEach(viewModel.images)` with `ForEach(viewModel.elements)`
- Switch on element type to render appropriate view (SingleImageView / TextElementView / StickerElementView)
- Maintain Z-order via array position + `.zIndex(Double(index))`

**Gesture Integration:**
- Extract gesture handlers from `SingleImageView` into shared helpers
- Apply drag, pinch, rotate gestures uniformly to all element types
- Add double-tap gesture to text elements for editing
- Long-press on any element shows action overlay

**Action Overlay Enhancement:**
- Update existing overlay to show element-specific buttons:
  - **Images**: Edit, Crop, Delete, Bring to Front, Send to Back
  - **Text**: Edit, Delete, Bring to Front, Send to Back
  - **Stickers**: Delete, Bring to Front, Send to Back
- Z-order actions call `viewModel.moveElementToFront(id)` / `moveElementToBack(id)`

---

#### [MODIFY] [GridEditingView.swift](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/Views/GridEditingView.swift)

**Toolbar Additions:**
- Add "Add Text" button (SF Symbol: `textformat`) next to "Add Photos"
- Add "Add Sticker" button (SF Symbol: `face.smiling`) next to "Add Text"
- Show `TextEditorView` sheet when text button tapped or text element edited
- Show `StickerPickerView` sheet when sticker button tapped

---

### Localization

#### [MODIFY] [Localizable.strings (en)](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/en.lproj/Localizable.strings)

Add English strings for:
- Text Editor: "Add Text", "Edit Text", "Font", "Size", "Color", "Alignment", "Background", "None", "Solid", "Semi-transparent", "Done", "Double tap to edit"
- Sticker Picker: "Add Sticker", "Emoji", "Icons", "Search Icons", category names
- Element Actions: "Edit", "Delete", "Bring to Front", "Send to Back"

#### [MODIFY] [Localizable.strings (zh-Hant)](file:///Users/tsaipingjui/Documents/InsGrids/InstaBorderApp/zh-Hant.lproj/Localizable.strings)

Add Traditional Chinese translations for all new UI strings.

---

## Verification Plan

### Automated Tests

**Note**: This project does not currently have unit tests. Verification will rely on manual testing with comprehensive scenarios.

### Manual Verification

#### 1. Text Element Lifecycle
- Open app → Freeform mode → Tap "Add Text" → Verify text editor opens with default text
- Change font to "Georgia", size to 48pt, color to red → Verify preview updates
- Add solid white background → Tap Done → Verify text appears centered on canvas
- Double-tap text → Verify editor reopens with saved values
- Save edited text → Verify changes persist
- Long-press text → Verify action overlay shows: Edit, Delete, Bring to Front, Send to Back

#### 2. Sticker Element Lifecycle
- Tap "Add Sticker" → Verify picker opens with Emoji and Stickers tabs
- Select "🎉" from Emoji tab → Verify sticker appears at canvas center
- Tap "Add Sticker" → Switch to Stickers tab → Select "heart.fill" → Verify red heart icon appears
- Search "star" → Verify filtered results show star-related symbols
- Long-press sticker → Verify action overlay shows: Delete, Bring to Front, Send to Back

#### 3. Gesture Interactions
- Create canvas with 2 images, 2 text elements, 2 stickers
- Drag each element → Verify smooth movement with edge snapping
- Pinch-zoom on text → Verify scales uniformly
- Two-finger rotate on sticker → Verify rotates with snap to 0°/90°/180°/270°
- Verify gestures don't interfere between elements

#### 4. Z-Order Management
- Create overlapping elements: image → text → sticker → image
- Long-press bottom image → Tap "Bring to Front" → Verify moves on top
- Long-press top sticker → Tap "Send to Back" → Verify moves to bottom
- Verify Z-order persists in visual rendering

#### 5. Auto-Save and Restore
- Create composition with text and stickers
- Wait 5+ seconds for auto-save
- Force quit app (swipe up in app switcher)
- Reopen app → Verify restore prompt appears
- Tap "Restore" → Verify all elements recreate with exact positions/formatting

#### 6. High-Resolution Export
- Create 2×2 grid with large text spanning tiles and stickers near boundaries
- Export to Photos
- Open exported tiles in Photos app
- Zoom in on text → Verify crisp rendering (not pixelated)
- Zoom in on SF Symbols → Verify high quality
- View in Instagram grid layout → Verify tiles align perfectly

#### 7. Localization
- System Settings → Language → English
- Open app → Verify all new UI shows English strings
- System Settings → Language → 繁體中文
- Open app → Verify all new UI shows Traditional Chinese strings
- Create text element with Chinese characters → Verify renders correctly

#### 8. Edge Cases
- Create text with 500 characters → Verify editor handles gracefully
- Add 30 stickers → Verify performance remains smooth
- Rotate text 45° spanning 4 tiles → Export → Verify renders correctly
- Create text with only whitespace → Verify visible on canvas
- Test on iPhone SE, iPhone 15 Pro, iPhone 15 Pro Max → Verify UI layouts correctly

#### 9. Backward Compatibility
- **Migration Test**: If you have an existing auto-saved session from before this change:
  1. Update to new version
  2. Open app → Restore session
  3. Verify images restore correctly
  4. Add text/sticker → Save
  5. Verify new format persists
  
**Expected Results**: All manual tests should pass without crashes, visual glitches, or data loss. Text and stickers should export at high resolution matching image quality.
