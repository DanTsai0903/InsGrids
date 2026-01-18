# Change: Expand Emoji Library to Include All iOS Emojis

## Why

The current emoji picker in InsGrids contains only 160 emojis across 8 basic categories, representing a small fraction of the 3,000+ emojis available in iOS. This limited selection frustrates users who expect access to the full range of modern emojis when decorating their compositions. Users familiar with the iOS keyboard emoji picker expect to find:

- All facial expressions and emotions (not just 20 smileys)
- Complete sets of flags, symbols, and objects
- Recent emoji additions (skin tones, gender variants, new Unicode versions)
- Familiar categorization matching the iOS keyboard experience

The gap between user expectations and current functionality reduces the creative value of the sticker feature, especially for social media content where emoji usage is ubiquitous and diverse.

## What Changes

This change enhances the **existing sticker emoji picker** by:

### 1. Comprehensive Emoji Library
- **Expand from 160 to ~1,800 emojis** covering all major iOS emoji categories
- **Reorganize into 8 iOS-standard categories**:
  1. 😀 **Smileys & People** (~500 emojis) - Faces, gestures, people, body parts, clothing
  2. 🐱 **Animals & Nature** (~150 emojis) - Animals, plants, weather, natural phenomena
  3. 🍕 **Food & Drink** (~130 emojis) - Food items, beverages, utensils
  4. ⚽ **Activity** (~90 emojis) - Sports, games, hobbies, arts, entertainment
  5. 🚗 **Travel & Places** (~120 emojis) - Transportation, buildings, locations, maps
  6. 💡 **Objects** (~250 emojis) - Technology, household items, tools, clothing
  7. ❤️ **Symbols** (~280 emojis) - Hearts, geometric shapes, arrows, signs, zodiac
  8. 🏳️ **Flags** (~270 emojis) - Country and regional flags

- **Use category representative emojis as icons** (e.g., 😀 for Smileys, 🐱 for Animals)
- **Maintain existing UI structure**: Scrollable category tabs + grid layout
- **No breaking changes**: Same `EmojiPickerView` API and integration with `StickerPickerView`

### 2. Data Organization
- Replace current `emojis: [(String, [String])]` array with comprehensive emoji lists
- Group emojis logically within categories (e.g., faces → hand gestures → people)
- Include common skin tone variants and gender options where applicable
- Follow Unicode emoji ordering standards for consistency

### 3. Emoji Search Functionality
- **Search bar above category tabs**: Text field with search icon and clear button
- **Real-time search**: Filter emojis across all categories as user types
- **Search algorithm**: 
  - Match emoji names/keywords (e.g., "heart" finds ❤️, 💛, 💚, etc.)
  - Search by category names (e.g., "food" shows all food emojis)
  - Case-insensitive matching
- **Search results display**: Grid view showing all matching emojis from all categories
- **Empty state**: "No results found" message when search returns no matches
- **Clear search**: Tapping X button returns to category view

## Impact

- **Affected specs**: 
  - **MODIFIED**: `sticker-elements` (from `add-text-and-stickers` change) - Update emoji picker capability description

- **Affected code**:
  - **MODIFY**: `InstaBorderApp/Views/Components/EmojiPickerView.swift`
    - Replace `emojis` array with comprehensive emoji library
    - Add emoji name/keyword mapping for search
    - Add search bar UI above category tabs
    - Add search filtering logic
    - Update category count and content
    - No API changes - maintains `onSelect(String)` callback
  
- **No localization changes needed**: Category icons are universal emoji symbols
- **No new dependencies**: Pure data update using standard Swift string literals
- **Minimal performance impact**: `LazyVGrid` already handles large lists efficiently
- **Backward compatibility**: Existing emoji stickers remain valid

## Non-Goals

- ❌ Emoji skin tone selector UI (include variants directly in grid)
- ❌ Recently used emoji tracking
- ❌ Custom emoji uploads
- ❌ Animated emoji/memoji support
- ❌ Advanced search features (fuzzy matching, search history, suggestions)
