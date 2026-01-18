# Remove Text and Sticker Scale Upper Limit

## Summary

Allow text and sticker elements to be scaled to unlimited sizes via pinch-to-zoom gestures. Currently, both element types are constrained to a maximum scale of 4.0×, which limits creative flexibility.

## Motivation

Users want the freedom to make text and stickers as large as needed without artificial constraints. The 4.0× upper limit was originally set as a conservative boundary, but in practice:

- Large text is common for emphasis or artistic layouts
- Oversized stickers can serve as decorative backgrounds
- The canvas already has its own zoom limits for navigation

## Proposed Changes

Remove the upper scale limit (currently 4.0×) for:
1. **Text elements** in `TextElementView.swift`
2. **Sticker elements** in `StickerView.swift`

Keep the lower limit (0.3×) to prevent elements from becoming too small to interact with.

## Scope

- **In scope**: Removing upper scale limit for text and sticker elements
- **Out of scope**: Photo slot scaling (remains unchanged), canvas zoom limits

## Files to Modify

| File | Change |
|------|--------|
| `InstaBorderApp/Views/Components/TextElementView.swift` | Remove `min(4.0, ...)` constraint |
| `InstaBorderApp/Views/Components/StickerView.swift` | Remove `min(4.0, ...)` constraint |

## Risk Assessment

- **Low risk**: Simple constraint removal with no architectural impact
- **Memory**: Large text is rendered as vector graphics (scalable), no memory concern
- **UX**: Users can always scale back down if they go too large
