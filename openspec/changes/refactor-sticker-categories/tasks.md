## 1. Implementation

- [x] 1.1 Update `StickerType` enum in `CanvasElement.swift`
  - [x] Remove `.emoji` case
  - [x] Add `.customSticker` case
  - [x] Keep `.sfSymbol` case
- [x] 1.2 Create `CustomStickerCategory.swift` model
  - [x] Define struct with `id`, `name`, `localizedKey`, `stickers` properties
  - [x] Add `allCategories` static property (initially empty or placeholder)
  - [x] Add `searchStickers()` method
- [x] 1.3 Update `StickerPickerView.swift`
  - [x] Remove emoji tab (currently tag 0)
  - [x] Rename "Stickers" tab to "Icon" tab (becomes tag 0)
  - [x] Add new "Sticker" tab (tag 1)
  - [x] Remove `emojiTab` computed property
  - [x] Rename `stickersTab` to `iconTab`
  - [x] Create `stickerTab` computed property with category UI
- [x] 1.4 Update `StickerView.swift`
  - [x] Keep `.emoji` case for backward compatibility (read-only)
  - [x] Add `.customSticker` case rendering
  - [x] Handle placeholder/missing custom stickers gracefully
- [x] 1.5 Update `StickerManager.swift`
  - [x] Remove `createEmojiSticker()` method
  - [x] Keep SF Symbol methods
  - [x] Add `createCustomSticker()` method (for future use)
- [ ] 1.6 Delete `EmojiPickerView.swift`
- [x] 1.7 Remove factory method `StickerElement.emoji()` in `CanvasElement.swift`
- [x] 1.8 Add factory method `StickerElement.customSticker()` in `CanvasElement.swift`

## 2. Localization

- [x] 2.1 Update English strings (`en.lproj/Localizable.strings`)
  - [x] Remove or comment: `"emoji.picker.title"`, `"emoji.picker.clear"`, `"Emoji"`
  - [x] Change `"Stickers" = "Icon";`
  - [x] Add `"Icon" = "Icon";`
  - [x] Add `"Sticker" = "Sticker";`
  - [x] Add `"sticker.comingSoon" = "Custom stickers coming soon";`
- [x] 2.2 Update Chinese strings (`zh-Hant.lproj/Localizable.strings`)
  - [x] Remove or comment: `"emoji.picker.title"`, `"emoji.picker.clear"`, `"Emoji"`
  - [x] Change `"Stickers" = "圖示";`
  - [x] Add `"Icon" = "圖示";`
  - [x] Add `"Sticker" = "貼圖";`
  - [x] Add `"sticker.comingSoon" = "個性化貼圖即將推出";`

## 3. Documentation

- [x] 3.1 Create developer guide for adding custom stickers
  - [x] Document category architecture
  - [x] Provide step-by-step guide for adding new stickers
  - [x] Include asset preparation guidelines
  - [x] Add troubleshooting section

## 4. Verification

- [x] 4.1 Build verification
  - [x] Project builds without errors
  - [x] No compiler warnings related to changes
- [ ] 4.2 UI verification
  - [ ] Sticker picker opens correctly
  - [ ] Only "Icon" and "Sticker" tabs appear (no "Emoji" tab)
  - [ ] Icon tab shows SF Symbols with categories
  - [ ] Sticker tab shows placeholder message
- [ ] 4.3 Functionality verification
  - [ ] Can add icons to canvas
  - [ ] Icons can be moved, rotated, scaled
  - [ ] Icon color picker works
  - [ ] Cannot add new emoji via sticker picker
- [ ] 4.4 Backward compatibility verification
  - [ ] Old saved grids with emoji stickers still render
  - [ ] Emoji stickers display correctly (read-only)
  - [ ] No crashes when opening old files
- [x] 4.5 OpenSpec validation
  - [x] Run `openspec validate refactor-sticker-categories --strict`
  - [x] Resolve all validation errors
