# Tasks: Add Draggable Grid Lines

## 1. Model Layer
- [x] 1.1 Create `DimensionOverrides` struct in `LayoutConfiguration.swift` with Codable conformance
  - File: `InstaBorderApp/Models/LayoutConfiguration.swift` (lines 3-24)
  - Stores line positions as key-value pairs with format "h0.5000" or "v0.5000"
- [x] 1.2 Add `dimensionOverrides` property to `LayoutConfiguration`
  - Added at line 33: `var dimensionOverrides: DimensionOverrides = DimensionOverrides()`
  - Codable support added with backward compatibility (lines 78-79)
- [x] 1.3 Add `DraggableLine` model to represent an interior line (orientation, position, affected slot indices)
  - File: `InstaBorderApp/Models/DraggableLine.swift`
  - Includes `LineOrientation` enum (horizontal/vertical)
  - Has `pointsToCorner()` static method to detect non-draggable lines
- [x] 1.4 Add `LayoutTemplate.detectDraggableLines()` method to identify which interior lines can be dragged
  - Implemented in `InstaBorderApp/Models/LayoutTemplate.swift` (lines 352-433)
  - Detects interior lines between adjacent slots
  - Excludes lines pointing to slot corners

## 2. ViewModel Updates
- [x] 2.1 Add `draggableLines: [DraggableLine]` computed property to `LayoutEditorViewModel`
  - Implemented at lines 155-157: calls `template.detectDraggableLines()`
- [x] 2.2 Add `updateLinePosition(_ line: DraggableLine, to newPosition: CGFloat)` method
  - Implemented at lines 168-177 in `LayoutEditorViewModel.swift`
  - Includes position clamping logic
- [x] 2.3 Implement minimum edge constraint logic (prevent positions < 0.1 or > 0.9)
  - Implemented with `minSlotEdge = 0.1` constant (line 165)
  - Clamping applied in `updateLinePosition()`: `min(max(newPosition, minSlotEdge), 1.0 - minSlotEdge)`
- [x] 2.4 Add `appliedSlots: [LayoutSlotShape]` computed property that applies dimension overrides to template slots
  - Implemented at lines 160-162: calls `template.appliedSlots(with: config.dimensionOverrides)`
  - Method `appliedSlots()` implemented in `LayoutTemplate.swift` (line 436+)

## 3. View Layer
- [x] 3.1 Create `DraggableLinesOverlay` view to render drag handles on interior lines
  - File: `InstaBorderApp/Views/Components/DraggableLinesOverlay.swift` (lines 1-44)
  - Shows handles only when adjacent slot is active
- [x] 3.2 Create `DragLineHandle` subview with drag gesture and visual feedback
  - Implemented in same file (lines 46-149)
  - Blue circular handle with arrow icon (↕ or ↔)
  - Scales up 1.2× during drag with spring animation
- [x] 3.3 Integrate `DraggableLinesOverlay` into `LayoutEditorView` canvas
  - Integrated at line 440: `DraggableLinesOverlay(viewModel:contentSize:activeSlotIndex:)`
- [x] 3.4 Ensure drag gestures don't conflict with slot selection or photo pan gestures
  - Handles appear only when slot is active (`shouldShowHandle(for:)` check)
  - Uses `minimumDistance: 1` to avoid accidental activation

## 4. Rendering Updates
- [x] 4.1 Update slot rendering to use `appliedSlots` instead of `template.slots`
  - Updated in `LayoutEditorViewModel.swift` line 241: `let slotsToRender = appliedSlots`
- [x] 4.2 Update final image export to respect dimension overrides
  - Export uses `appliedSlots` which includes dimension overrides

## 5. Localization
- [x] 5.1 Add localized strings for any new UI labels (if applicable)
  - No new UI text strings needed (feature uses visual drag handles only)

## 6. Verification
- [ ] 6.1 Manual test: Drag horizontal line in grid1x2 template, verify slots resize
- [ ] 6.2 Manual test: Drag vertical line in grid2x1 template, verify slots resize
- [ ] 6.3 Manual test: Verify diagonal2 template has NO draggable lines
- [ ] 6.4 Manual test: Verify minimum edge constraint prevents slots from being too small
- [ ] 6.5 Manual test: Save and reload layout, verify dimension overrides persist
- [ ] 6.6 Manual test: Export image with resized slots, verify output is correct
