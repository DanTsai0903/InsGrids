# Change: Remove Text and Sticker Scale Upper Limit

## Why

The current text and sticker elements have a maximum scale limit of 4.0x, which restricts creative flexibility. Users sometimes need to create very large text overlays or stickers that span across the entire canvas, especially for bold visual statements or creative emphasis. The artificial 4.0x cap prevents users from achieving their desired artistic vision.

## What Changes

This change **removes the upper scale limit** for text and sticker elements in the Layout Editor:

### 1. TextElementView Scale Limit
- **Before**: `onUpdateScale(max(0.3, min(4.0, newScale)))`
- **After**: `onUpdateScale(max(0.3, newScale))`

### 2. StickerView Scale Limit
- **Before**: `onUpdateScale(max(0.3, min(4.0, newScale)))`
- **After**: `onUpdateScale(max(0.3, newScale))`

### Preserved Behavior
- **Minimum scale of 0.3** remains to prevent elements from becoming too small to interact with
- Pinch-to-zoom gesture behavior unchanged
- Export quality for large elements preserved (rendering at scale)

## Impact

- **Affected code**:
  - **MODIFY**: `InstaBorderApp/Views/Components/TextElementView.swift` - Remove `min(4.0, ...)` constraint
  - **MODIFY**: `InstaBorderApp/Views/Components/StickerView.swift` - Remove `min(4.0, ...)` constraint

- **No localization changes needed**
- **No breaking changes**
- **Performance**: Minimal impact, large elements may require slightly more memory during export

## Non-Goals

- ❌ Removing the minimum scale limit (0.3x preserved for usability)
- ❌ Custom scale limit settings
- ❌ Scale limit warnings or confirmations
