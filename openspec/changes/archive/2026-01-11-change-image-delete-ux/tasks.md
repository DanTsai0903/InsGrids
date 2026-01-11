# Tasks: Change Image Delete UX

## Phase 1: Remove Drag-to-Trash

- [x] Remove trash zone UI (`trashZone` ViewBuilder in `GridEditingView.swift`)
- [x] Remove trash-related state variables (`draggedImageId`, `dragLocationGlobal`, `isNearTrash`, `trashIconGlobalY`)
- [x] Remove `updateTrashIconPosition` function
- [x] Remove `handleImageDrag` function
- [x] Clean up `onImageDragLocation` callback in `FreeformCanvasView`
- [x] Remove `CanvasGlobalFrameKey` preference key and related code

## Phase 2: Implement Selection Mechanism

- [x] Add `@Published var selectedImageId: UUID?` to `GridViewModel`
- [x] Add `selectImage(id:)` and `deselectImage()` methods
- [x] Update `SingleImageView` to accept tap gesture for selection
- [x] Implement tap detection that distinguishes from drag gesture

## Phase 3: Visual Selection Feedback

- [x] Add selection border/glow effect to selected image
- [x] Animate selection state changes
- [x] Ensure selection indicator scales with image

## Phase 4: Toolbar Delete Button

- [x] Add contextual delete button to bottom toolbar
- [x] Show delete button only when `selectedImageId != nil`
- [x] Implement delete action with haptic feedback
- [x] Auto-deselect after deletion

## Phase 5: Tap-to-Deselect

- [x] Add tap gesture on canvas background
- [x] Deselect current image when tapping empty area
- [x] Ensure gesture doesn't conflict with canvas zoom

## Validation

### Manual Testing
- [x] Build and run on iOS Simulator or device
- [x] Add multiple images to canvas
- [x] Tap an image → Should show selection indicator + delete button
- [x] Tap delete button → Image should be deleted
- [x] Tap empty area → Selection should be cleared
- [x] Zoom canvas → Selection and deletion should work correctly
- [x] Rotate/scale image → Should not trigger deletion
