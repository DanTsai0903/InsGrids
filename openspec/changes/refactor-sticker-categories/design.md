# Custom Stickers Developer Guide

This guide explains how to add custom stickers to the InsGrids app after the sticker refactoring is complete.

## Architecture Overview

Custom stickers use a category-based organization similar to SF Symbol icons:

- **CustomStickerCategory** - Organizes stickers into browsable categories
- **StickerType.customSticker** - New enum case for custom sticker elements  
- **Asset-based** - Stickers stored in `Assets.xcassets` for easy management

## Adding Custom Stickers

### 1. Prepare Sticker Assets

Add sticker images to Xcode:
1. Open `Assets.xcassets`
2. Create folder: `CustomStickers/[CategoryName]` (e.g., `CustomStickers/Emotions`)
3. Add PNG images with transparency (recommended: 512x512px)
4. Name descriptively (e.g., `happy_face`, `sad_face`)

### 2. Define Category

Update `CustomStickerCategory.swift`:

```swift
static let allCategories: [CustomStickerCategory] = [
    CustomStickerCategory(
        name: "Emotions",
        localizedKey: "sticker.category.emotions",
        stickers: ["happy_face", "sad_face", "love_face"]
    ),
    // Add more categories...
]
```

### 3. Add Localization

**en.lproj/Localizable.strings:**
```
"sticker.category.emotions" = "Emotions";
```

**zh-Hant.lproj/Localizable.strings:**
```
"sticker.category.emotions" = "情緒";
```

### 4. Test

1. Build and run
2. Tap "Add Sticker" → "Sticker" tab
3. Verify category and stickers appear

## Custom Sticker Category Model

```swift
struct CustomStickerCategory: Identifiable {
    let id: UUID
    let name: String           // Internal name
    let localizedKey: String   // Localization key
    let stickers: [String]     // Array of asset names
    
    static let allCategories: [CustomStickerCategory]
    static func searchStickers(_ query: String) -> [String]
}
```

## Future Enhancements

- Downloadable sticker packs
- User-created stickers
- Animated stickers (GIF/Lottie)
- AI-generated stickers
