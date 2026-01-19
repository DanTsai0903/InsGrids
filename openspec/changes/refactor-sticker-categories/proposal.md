# Change: Refactor Sticker Categories - Remove Emoji, Add Custom Stickers

## Why

The current sticker implementation includes both emoji and SF Symbol icons, but emoji functionality is redundant with the text tool (which already supports emoji input). Additionally, there's no architecture for adding custom, personalized stickers that users might want in the future.

This refactoring will:
- Remove emoji from stickers (users can add emoji via text tool)
- Rename "Stickers" to "Icon" for clarity (SF Symbols are icons, not stickers)
- Add a new "Sticker" category with architecture for future custom stickers organized by categories
- Improve user understanding - "Icon" for system symbols, "Sticker" for custom graphics

## What Changes

- **Remove Emoji Tab**: Delete emoji picker tab from sticker picker UI since text tool handles emoji
- **Rename SF Symbols Tab**: Change "Stickers" tab to "Icon" tab for clearer terminology
- **Add Custom Sticker Tab**: Add new "Sticker" tab with category-based architecture
  - Similar structure to SF Symbol categories (browse by category, search functionality)
  - Initially shows placeholder content ("Custom stickers coming soon")
  - Designed to support future expansion (custom images, downloadable sticker packs, etc.)
- **Update Data Model**: 
  - Remove `StickerType.emoji` enum case
  - Add `StickerType.customSticker` enum case
  - Create `CustomStickerCategory` model for organizing custom stickers
- **Backward Compatibility**: Old files with emoji stickers still render correctly (read-only)

## Impact

- **Affected specs**:
  - **MODIFIED**: `sticker-elements` - Remove emoji requirements, add custom sticker requirements
  
- **Affected code**:
  - `StickerPickerView.swift` - Remove emoji tab, rename tabs, add custom sticker tab
  - `EmojiPickerView.swift` - DELETE (no longer needed)
  - `CanvasElement.swift` - Update `StickerType` enum
  - `CustomStickerCategory.swift` - NEW model for custom sticker organization
  - `StickerView.swift` - Add `customSticker` rendering
  - `StickerManager.swift` - Remove emoji methods
  - `Localizable.strings` (en + zh-Hant) - Update terminology, add new strings

- **User Impact**: 
  - Existing emoji stickers in saved grids remain visible (backward compatible)
  - No way to add new emoji via sticker picker (must use text tool)
  - Clearer terminology: "Icon" for system symbols, "Sticker" for custom graphics
