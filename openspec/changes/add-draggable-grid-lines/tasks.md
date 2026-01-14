# Tasks: Add Draggable Grid Lines

## 1. Model Layer
- [ ] 1.1 Create `DimensionOverrides` struct in `LayoutConfiguration.swift` with Codable conformance
- [ ] 1.2 Add `dimensionOverrides` property to `LayoutConfiguration`
- [ ] 1.3 Add `DraggableLine` model to represent an interior line (orientation, position, affected slot indices)
- [ ] 1.4 Add `LayoutTemplate.detectDraggableLines()` method to identify which interior lines can be dragged

## 2. ViewModel Updates
- [ ] 2.1 Add `draggableLines: [DraggableLine]` computed property to `LayoutEditorViewModel`
- [ ] 2.2 Add `updateLinePosition(_ line: DraggableLine, to newPosition: CGFloat)` method
- [ ] 2.3 Implement minimum edge constraint logic (prevent positions < 0.1 or > 0.9)
- [ ] 2.4 Add `appliedSlots: [LayoutSlotShape]` computed property that applies dimension overrides to template slots

## 3. View Layer
- [ ] 3.1 Create `DraggableLinesOverlay` view to render drag handles on interior lines
- [ ] 3.2 Create `DragLineHandle` subview with drag gesture and visual feedback
- [ ] 3.3 Integrate `DraggableLinesOverlay` into `LayoutEditorView` canvas
- [ ] 3.4 Ensure drag gestures don't conflict with slot selection or photo pan gestures

## 4. Rendering Updates
- [ ] 4.1 Update slot rendering to use `appliedSlots` instead of `template.slots`
- [ ] 4.2 Update final image export to respect dimension overrides

## 5. Localization
- [ ] 5.1 Add localized strings for any new UI labels (if applicable)

## 6. Verification
- [ ] 6.1 Manual test: Drag horizontal line in grid1x2 template, verify slots resize
- [ ] 6.2 Manual test: Drag vertical line in grid2x1 template, verify slots resize
- [ ] 6.3 Manual test: Verify diagonal2 template has NO draggable lines
- [ ] 6.4 Manual test: Verify minimum edge constraint prevents slots from being too small
- [ ] 6.5 Manual test: Save and reload layout, verify dimension overrides persist
- [ ] 6.6 Manual test: Export image with resized slots, verify output is correct
