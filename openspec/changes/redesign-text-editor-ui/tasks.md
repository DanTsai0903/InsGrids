# Implementation Tasks - Text Editor UI Redesign

## Phase 1: Preparation
- [x] Review reference images and save to project assets
- [x] Audit existing TextEditorView code and identify reusable components
- [x] Test current text editing flow to understand baseline behavior

## Phase 2: Remove Delete Button
- [x] Remove delete button overlay for text elements in `GridCanvasView.swift`
- [x] Remove `onDeleteText` callback usage for manual delete
- [x] Keep underlying delete function for auto-delete on empty text

## Phase 3: Add Tap-to-Edit
- [x] Update `TextElementView.swift` to handle single tap gesture
- [x] Wire tap gesture to call `onEditText` callback
- [x] Ensure tap doesn't interfere with drag/scale/rotate gestures
- [x] Test gesture discrimination (tap vs drag)

## Phase 4: Redesign TextEditorView Layout
- [x] Replace `ScrollView` with `ZStack` overlay layout
- [x] Add semi-transparent background overlay
- [x] Position text preview on canvas (at element position)
- [x] Add text input field at top of screen
- [x] Verify keyboard handling doesn't obscure controls

## Phase 5: Create Bottom Control Bar
- [x] Design horizontal control bar at bottom
- [x] Add Font button ("Aa" icon) → sheet to FontPickerView
- [x] Add Color button (circle) → toggle inline palette
- [x] Add Alignment button → cycle through left/center/right
- [x] Add Background button → cycle through none/solid/semi-transparent
- [x] Add Done button → save and dismiss
- [x] Style buttons with consistent size and spacing

## Phase 5.5: Custom Color Picker & Eyedropper
- [x] Create CustomColorPaletteView with preset colors
- [x] Create EyedropperOverlayView for canvas color sampling
- [x] Integrate inline palette in TextEditorView
- [x] Add 3 palette pages (Basic, Warm, Cool) with swipe navigation
- [x] Add eyedropper mode with pin marker showing sampled color
- [x] Pass `canvasSnapshot` (UIImage) from parent view for eyedropper
- [x] Fix color extraction (BGRA to RGBA format issue)
- [x] Real-time text preview color update during eyedropper drag
- [x] Hide live canvas during eyedropper (solid black background)
- [x] Expand snapshot to include content beyond canvas bounds

## Phase 6: Add Vertical Size Slider
- [x] Create vertical slider component
- [x] Configure range 12-72pt with step of 1
- [x] Add visual size indicator ("24pt" label)
- [x] Move slider to LEFT edge of screen
- [x] Add slide-in animation when actively using slider
- [x] Bind slider to `fontSize` state
- [x] Test slider interaction doesn't conflict with other gestures

## Phase 7: Implement Auto-Delete Logic
- [x] Update `saveAndDismiss()` to check if text is empty
- [x] If empty and editing existing element → trigger delete
- [x] If empty and creating new element → just dismiss
- [x] Ensure proper cleanup and callback handling

## Phase 8: Update Icon (Optional Color)
- [x] Design or find "Aa + 文字" icon asset
- [x] Add icon to project assets
- [x] Update text tool button to use new icon
- [x] Verify icon rendering at different sizes

## Phase 9: Text Input Improvements
- [x] Native blinking cursor using visible TextField
- [x] Cursor color matches text color via `.tint()`
- [x] Keyboard stays visible when tapping color buttons
- [x] Unified TextField (single instance) for reliable state

## Phase 10: Known Limitations
- [ ] Text background extends full width in editor (SwiftUI TextField limitation)
  - Note: Actual TextElement on canvas uses Text view which wraps correctly
  - Advanced solution: UITextView wrapper with intrinsicContentSize

## Verification
- [x] Text editor shows canvas overlay
- [x] All settings accessible via buttons (no scrolling needed)
- [x] Size adjustable via vertical slider
- [x] Tap on text opens editor
- [x] Empty text auto-deletes element
- [x] Eyedropper correctly samples colors
- [x] Real-time color preview during eyedropper
- [ ] Visual style matches Instagram reference (partial - background width differs)
- [x] All existing text functionality preserved
