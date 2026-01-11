## 1. Models and Core Logic
- [x] 1.1 Create `GridLayout` model (rows, cols, cell data, Codable, Identifiable)
- [x] 1.2 Create `GridCell` model (position, assigned image, scale, offset, emoji, backgroundColor)
- [x] 1.3 Create `GridProcessor` with image slicing method
- [x] 1.4 Add tile generation with proper 4:5 aspect ratio per cell
- [ ] 1.5 Test GridProcessor with various image sizes and grid dimensions
- [x] 1.6 Add emoji rendering to GridProcessor using CoreGraphics

## 2. View Models
- [x] 2.1 Create `GridViewModel` class conforming to ObservableObject
- [x] 2.2 Add @Published properties for grid layout, images, cells, and emoji
- [x] 2.3 Implement image assignment to grid cells
- [x] 2.4 Implement image repositioning/scaling within cells
- [x] 2.5 Add validation for grid completeness before export
- [x] 2.6 Implement auto-save logic (save every 3 seconds to UserDefaults)
- [x] 2.7 Implement session restore logic (load on appear, prompt user)
- [x] 2.8 Add emoji add/remove/update methods

## 3. User Interface Components
- [x] 3.1 Create `GridDimensionPicker` component (custom rows/cols input + quick presets)
- [x] 3.2 Add quick preset buttons (1×2, 2×2, 2×3, 3×3)
- [x] 3.3 Add validation for grid size limits (max 6×6)
- [x] 3.4 Create `GridCanvasView` with 4:5 ratio grid overlay
- [x] 3.5 Add drag-and-drop gesture handlers for image placement
- [ ] 3.6 Implement pinch-to-zoom for image scaling within cells
- [x] 3.7 Add visual indicators for empty vs filled cells
- [x] 3.8 Create grid preview with Instagram-style 4:5 spacing
- [x] 3.9 Create `EmojiPickerView` component
- [x] 3.10 Add emoji tap gesture to cells
- [x] 3.11 Create background color picker for empty cells

## 4. Main Grid View
- [x] 4.1 Create `GridEditingView` as main grid editing screen
- [x] 4.2 Add photo picker integration for multiple images
- [x] 4.3 Integrate GridDimensionPicker and GridCanvasView
- [x] 4.4 Add top toolbar with back button, preset button, and export button
- [x] 4.5 Add image library panel at bottom for available images
- [x] 4.6 Integrate EmojiPickerView as modal sheet
- [x] 4.7 Add background color picker UI
- [ ] 4.8 Add auto-save indicator (small icon showing "Saved" status)

## 5. Navigation Integration
- [x] 5.1 Modify `ContentView` to add "Freeform Grid" mode button
- [x] 5.2 Add navigation to GridEditingView
- [x] 5.3 Ensure proper state cleanup when switching modes
- [x] 5.4 Add restore session alert on navigation to grid mode

## 6. Preset Integration
- [ ] 6.1 Modify `Preset` model to include `PresetType` enum (border/grid)
- [ ] 6.2 Extend `PresetManager` to handle grid presets
- [ ] 6.3 Add save grid preset functionality
- [ ] 6.4 Add load grid preset functionality
- [ ] 6.5 Update `PresetsSheet` to filter by preset type
- [ ] 6.6 Add delete grid preset functionality
- [ ] 6.7 Test preset persistence with UserDefaults

## 7. Auto-Save System  
- [x] 7.1 Implement auto-save timer in GridViewModel (3-second interval)
- [x] 7.2 Add UserDefaults key for auto-save data
- [x] 7.3 Implement GridLayout serialization (Codable)
- [x] 7.4 Add session restore prompt on GridEditingView appear
- [x] 7.5 Implement discard auto-save functionality
- [x] 7.6 Clear auto-save after successful export
- [ ] 7.7 Test auto-save/restore with app termination

## 8. Export Functionality
- [x] 8.1 Extend `ImageExporter` with batch export method
- [x] 8.2 Implement sequential file naming (InsGrids_Grid_1.jpg to InsGrids_Grid_N.jpg)
- [x] 8.3 Add posting order numbering (left-to-right, top-to-bottom)
- [x] 8.4 Add export progress indicator with tile count
- [x] 8.5 Show success message with tile count
- [x] 8.6 Ensure emoji renders correctly in exported tiles

## 9. Localization
- [x] 9.1 Add English strings for grid UI elements
- [x] 9.2 Add Traditional Chinese translations
- [x] 9.3 Localize grid dimension labels (e.g., "2×2 Grid", "3×3 Grid")
- [x] 9.4 Localize emoji picker strings
- [x] 9.5 Localize auto-save/restore prompts
- [ ] 9.6 Localize preset-related strings

## 10. Memory Management & Testing
- [x] 10.1 Apply autoreleasepool to grid tile generation
- [ ] 10.2 Test with large grid sizes (6×6 = 36 tiles)
- [x] 10.3 Verify 12MP limit is maintained for each 4:5 tile
- [ ] 10.4 Test with high-resolution iPhone photos (48MP)
- [ ] 10.5 Verify no memory crashes on batch export
- [ ] 10.6 Test emoji rendering performance
- [ ] 10.7 Profile memory usage with Instruments

## 11. Instagram Compatibility Testing
- [ ] 11.1 Export 4:5 tiles from various grid dimensions
- [ ] 11.2 Post tiles to test Instagram account in order
- [ ] 11.3 Verify grid displays correctly in Instagram profile view
- [ ] 11.4 Check for any gaps or misalignments between tiles
- [ ] 11.5 Test with emoji overlays on actual Instagram posts

## 12. User Experience Polish
- [ ] 12.1 Add haptic feedback for image placement
- [ ] 12.2 Add haptic feedback for emoji selection
- [x] 12.3 Add grid size warning for grids > 4×4 (16 tiles)
- [ ] 12.4 Create help/tutorial for first-time users
- [x] 12.5 Add long-press gesture for cell options menu
- [ ] 12.6 Add visual feedback for auto-save status

## 13. Documentation
- [ ] 13.1 Update README with Freeform Grid feature description
- [ ] 13.2 Add grid usage instructions to README
- [ ] 13.3 Update architecture diagram in README
- [ ] 13.4 Document 4:5 aspect ratio requirement
- [ ] 13.5 Document emoji feature
- [ ] 13.6 Document preset integration
- [ ] 13.7 Document auto-save behavior
