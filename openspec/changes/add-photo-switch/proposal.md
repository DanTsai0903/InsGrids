# Change: Add Photo Switching Between Slots

## Why
Users need a quick way to swap photos between different slots in a layout without having to delete and re-add images. This improves the editing workflow and provides a more intuitive way to rearrange photos in a template.

## What Changes
- Add a "Switch" button to the long-press action menu (alongside Edit, Crop, Delete)
- Implement switch mode that allows users to select a target slot to swap photos
- Add visual indicators: orange glow on source slot, green highlight on valid target slots
- Implement swap animation with 0.3s easing for smooth transition
- Reset photo transforms (scale/offset) after swap to prevent unexpected positioning
- Support undo/redo for swap operations through existing snapshot system
- Provide haptic feedback for mode activation and successful swap

## Impact
- Affected specs: layout-editor (new capability spec being created)
- Affected code:
  - LayoutEditorView.swift:27-29 - Added switch mode state
  - LayoutEditorView.swift:332-348 - Added switch button to action menu
  - LayoutEditorView.swift:395-413 - Modified tap handling for switch mode
  - LayoutEditorView.swift:559-560 - Added switch mode parameters to LayoutSlotView
  - LayoutEditorView.swift:590-608 - Added visual indicators with animations
  - LayoutEditorViewModel.swift:81-100 - Added swapPhotos() method
