# Tasks: Fix Selection Border and Long-Press Delete

## Phase 1: Fix Selection Border Alignment

- [x] Remove duplicate `.position()`, `.scaleEffect()`, `.rotationEffect()` from overlay in `SingleImageView`
- [x] Remove duplicate `.rotationEffect()` on line 149
- [x] Verify border aligns correctly with image at all scales/rotations

## Phase 2: Implement Long-Press Delete

- [x] Remove `selectedImageId` from `GridViewModel`
- [x] Remove `selectImage()` and `deselectImage()` methods from `GridViewModel`
- [x] Remove `selectedImageId` binding from `FreeformCanvasView`
- [x] Remove `onSelectImage` and `onDeselect` callbacks from `FreeformCanvasView`
- [x] Remove `isSelected` property from `SingleImageView`
- [x] Remove selection overlay from `SingleImageView`
- [x] Add `.contextMenu` with delete option to `SingleImageView`
- [x] Remove selection mode from `bottomToolbar` in `GridEditingView`
- [x] Add localization for "Delete" menu item (uses existing `button.delete` key)

## Validation

### Manual Testing
- [x] Build and run on iOS Simulator or device
- [x] Add an image to canvas
- [x] Long-press on image → Should show context menu with "Delete" option
- [x] Tap "Delete" → Image should be deleted
- [x] Drag/scale/rotate image → Should work normally without any selection UI
- [x] Zoom canvas → Long-press delete should still work
