# Change: Add Slot Extend/Shorten Feature to Layout Editor

## Why
Users need more flexibility to customize layout proportions without switching templates. Currently, slot sizes are fixed by the template definition. This feature allows users to extend or shorten slots by dragging interior divider lines, similar to professional photo collage apps.

## What Changes
- Add interactive drag handles on interior divider lines between layout slots
- Enable extending/shortening slots by dragging divider lines horizontally or vertically
- Store slot size overrides in `LayoutConfiguration` for persistence
- Prevent extending/shortening for slots whose interior lines point to corners (to preserve shapes like triangles)
- Enforce minimum slot size constraints to prevent slots from becoming too small
- Add visual indicators (e.g., ↕ or ↔ icons) on draggable lines

## Impact
- Affected specs: `layout-grid-customization` (new spec)
- Affected code:
  - `LayoutTemplate.swift` - Add mutable slot dimensions
  - `LayoutConfiguration.swift` - Store dimension overrides
  - `LayoutEditorView.swift` - Add drag gesture handlers and visual indicators
  - `LayoutEditorViewModel.swift` - Add dimension update logic

## Constraints
- Interior lines that point to at least one corner are NOT draggable (to preserve slot shapes like triangles)
- Minimum slot edge length: 10% of canvas dimension (prevents unusably small slots)
