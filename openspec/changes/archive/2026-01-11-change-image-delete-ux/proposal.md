# Change Image Delete UX

## Summary

Replace the current **drag-to-trash** image deletion mechanism with a **tap-to-select + toolbar delete button** approach.

## Motivation

The current drag-to-trash implementation has fundamental problems with coordinate transformation when the canvas is zoomed and scrolled:
- Screen coordinates vs canvas coordinates conversion is complex
- GeometryReader cannot accurately track transformed element positions
- Users may accidentally delete images when zoomed in (gestures interpreted as near trash zone)

## Proposed Solution

### New Deletion Flow
1. **Tap image** → Image becomes selected (visual feedback shown)
2. **Bottom toolbar shows delete button** → Only when an image is selected
3. **Tap delete button** → Selected image is deleted with confirmation haptic
4. **Tap empty area** → Deselect current image
5. **Drag/scale/rotate** → Only manipulate image, no delete trigger

### Benefits
- ✅ No coordinate transformation needed
- ✅ Explicit user action required for deletion
- ✅ Works correctly at any zoom level
- ✅ Consistent with iOS design patterns (select then act)

## Scope

### In Scope
- Remove drag-to-trash zone UI and logic
- Add image selection state (`selectedImageId`)
- Add visual selection indicator (border/glow)
- Add delete button to bottom toolbar (contextual)
- Handle tap gestures for selection

### Out of Scope
- Multi-select deletion
- Undo functionality
- Confirmation dialog

## User Review Required

> [!IMPORTANT]
> This change removes the drag-to-trash feature entirely. Users will need to tap to select, then tap delete button.

## Related Changes
- `add-freeform-grid-layout` - The current freeform canvas implementation
