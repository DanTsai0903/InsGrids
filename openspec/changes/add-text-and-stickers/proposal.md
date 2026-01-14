# Change: Add Text and Sticker Capabilities to Canvas

## Why

InsGrids currently supports freeform image composition with photo adjustments, but users cannot add text labels, captions, or decorative elements to their compositions. This limits creative expression for social media posts, which commonly combine images with text overlays and decorative stickers. The existing emoji picker component exists but is not integrated into the canvas, leaving a gap in functionality.

Adding comprehensive text and sticker support will enable users to:
- Add captions, titles, and labels directly on the canvas
- Decorate compositions with emoji, icons, and graphic stickers
- Create more engaging social media content without external editing tools
- Match the creative capabilities expected from modern photo composition apps

## What Changes

- **Text Layer System**: Add text canvas elements with full editing capabilities
  - Text input with font selection (system fonts)
  - Size adjustment, color picker, and alignment options (left/center/right)
  - Background fill options (transparent, solid color, semi-transparent)
  - Full gesture support (drag, scale, rotate) matching image interactions
  - Integration with existing undo/redo stack and auto-save system

- **Enhanced Sticker System**: Expand beyond emoji to a comprehensive sticker library
  - Integrate existing EmojiPickerView into canvas as placeable elements
  - Add SF Symbols icon library with categories (arrows, shapes, symbols, nature, etc.)
  - Support for custom sticker packs (future extensibility)
  - Stickers behave like canvas elements (drag, scale, rotate, delete)
  - Z-order management for layering stickers with images and text

- **Unified Canvas Element Model**: Extend CanvasImage pattern to support multiple element types
  - Create `CanvasElement` protocol/enum supporting: Image, Text, Sticker
  - Unified gesture handling and rendering pipeline
  - Consistent interaction model across all element types
  - Export pipeline renders all elements at high resolution

- **Localization**: Add English and Traditional Chinese translations for all new UI strings

## Impact

- **Affected specs**: `freeform-grid` (add text and sticker requirements)
- **Affected code**:
  - `GridViewModel.swift` - Extend to manage text/sticker elements
  - `GridCanvasView.swift` - Add rendering for text/sticker layers
  - `CanvasImage` model - Generalize to `CanvasElement` with element types
  - `GridEditingView.swift` - Add text/sticker toolbar buttons and editors
  - `EmojiPickerView.swift` - Integrate into canvas element creation
  - New files: `TextEditorView.swift`, `StickerPickerView.swift`, `CanvasElement.swift`
  - `Localizable.strings` (en + zh-Hant) - Add new UI strings
  - Auto-save persistence - Extend `GridAutoSaveConfig` to save text/sticker data
  - Export pipeline - Render text/stickers at high resolution in tile export

- **Memory considerations**: Text and stickers are lightweight compared to images, minimal impact expected
- **Backward compatibility**: Existing auto-saved grids without text/stickers will load normally
