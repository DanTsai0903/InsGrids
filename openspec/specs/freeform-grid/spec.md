# freeform-grid Specification

## Purpose
TBD - created by archiving change add-freeform-grid-layout. Update Purpose after archive.
## Requirements
### Requirement: Grid Layout Configuration
The system SHALL allow users to select arbitrary grid layout dimensions (NxM) for creating multi-post Instagram compositions, with quick access to common presets.

#### Scenario: User selects custom grid dimensions
- **WHEN** user taps "Freeform Grid" mode and enters rows=3, columns=4 in the dimension picker
- **THEN** the system displays a 3x4 grid canvas with 12 empty cells

#### Scenario: User selects common preset
- **WHEN** user taps "2×2" quick preset button
- **THEN** the system displays a 2x2 grid canvas with 4 empty cells

#### Scenario: User switches between grid sizes
- **WHEN** user changes from 2x2 to 3x3 layout after placing images
- **THEN** the system preserves existing image placements in matching cells and adds new empty cells

#### Scenario: Grid dimension limits
- **WHEN** user tries to create a grid larger than 6×6
- **THEN** the system shows warning "Grid size limited to 6×6 (36 tiles) for memory safety"

#### Scenario: Available quick presets
- **WHEN** user opens the grid dimension picker
- **THEN** the system displays quick preset buttons: 1×2, 2×2, 2×3, 3×3, plus custom input

---

### Requirement: Image Assignment to Grid Cells
The system SHALL allow users to assign one or more images to grid cells through drag-and-drop or tap-to-assign interactions.

#### Scenario: Drag image from library to grid cell
- **WHEN** user drags an image from the image library panel onto an empty grid cell
- **THEN** the system assigns that image to the cell and displays it within the cell boundaries

#### Scenario: Replace image in occupied cell
- **WHEN** user drags a different image onto an already-occupied cell
- **THEN** the system replaces the existing image with the new image

#### Scenario: Remove image from cell
- **WHEN** user long-presses a cell and selects "Remove"
- **THEN** the system clears the image from that cell, leaving it empty

#### Scenario: Same image in multiple cells
- **WHEN** user assigns the same source image to multiple different cells
- **THEN** the system allows this and treats each cell independently with its own scale/offset

---

### Requirement: Image Positioning Within Cells
The system SHALL allow users to adjust the scale and position of images within individual grid cells using gesture controls.

#### Scenario: Pan to reposition image within cell
- **WHEN** user drags their finger on an image-filled cell
- **THEN** the system pans the image within the cell boundaries without affecting other cells

#### Scenario: Pinch to zoom image within cell
- **WHEN** user performs a pinch gesture on an image-filled cell
- **THEN** the system scales the image up or down while keeping it centered in the cell

#### Scenario: Image boundary constraints
- **WHEN** user scales image below 100% of cell size
- **THEN** the system prevents scaling below minimum threshold and fills remaining space with background color

#### Scenario: Set custom background color for empty space
- **WHEN** user taps background color picker and selects a color
- **THEN** empty space in all cells uses the selected background color

---

### Requirement: Grid Canvas Visualization
The system SHALL display a real-time preview of the grid composition with clear cell boundaries and image placements.

#### Scenario: Empty cells display placeholder
- **WHEN** a grid cell has no assigned image
- **THEN** the system displays a light gray placeholder with a "+" icon

#### Scenario: Grid overlay shows cell boundaries
- **WHEN** user is editing the grid
- **THEN** the system displays visible borders around each cell to show post boundaries

#### Scenario: Full grid preview without borders
- **WHEN** user taps "Preview" button
- **THEN** the system shows the complete composition without grid lines, as it will appear on Instagram

---

### Requirement: Image Slicing and Tile Generation
The system SHALL accurately slice the composed grid into individual 4:5 portrait tiles for Instagram posting.

#### Scenario: Generate tiles from grid composition
- **WHEN** user taps "Export" with a completed grid
- **THEN** the system processes the grid and generates N individual 4:5 portrait images (where N = rows × columns)

#### Scenario: Tiles maintain proper aspect ratio
- **WHEN** tiles are generated from any grid configuration
- **THEN** each tile SHALL have exactly 4:5 aspect ratio (portrait) suitable for Instagram

#### Scenario: Tile alignment verification
- **WHEN** tiles are placed in order on an Instagram grid
- **THEN** images SHALL align seamlessly with no gaps or overlaps at tile boundaries

#### Scenario: Handle partial grid (empty cells)
- **WHEN** some grid cells are empty during export
- **THEN** the system fills those tiles with the user-selected background color (default: white)

---

### Requirement: Sequential Tile Export
The system SHALL export grid tiles as numbered image files in the correct Instagram posting order (left-to-right, top-to-bottom).

#### Scenario: File naming convention
- **WHEN** system exports tiles from a 2x3 grid
- **THEN** files are named `InsGrids_Grid_1.jpg` through `InsGrids_Grid_6.jpg`

#### Scenario: Posting order matches numbering
- **WHEN** user posts tiles in numerical order (1, 2, 3...)
- **THEN** the Instagram grid displays the composition correctly with tile 1 at top-left

#### Scenario: Success message with tile count
- **WHEN** export completes successfully
- **THEN** the system displays "Successfully saved 6 grid tiles to Photos" (localized)

#### Scenario: Export progress indication
- **WHEN** system is generating and saving tiles
- **THEN** the system displays a progress indicator showing current tile number out of total (e.g., "Saving tile 3/9...")

---

### Requirement: Memory Management for Grid Processing
The system SHALL process grid tiles serially with autoreleasepool to prevent memory crashes when generating large grids.

#### Scenario: Serial tile processing
- **WHEN** generating tiles from a 3x3 grid (9 tiles)
- **THEN** the system processes tiles one at a time on a background thread, not in parallel

#### Scenario: Memory cleanup between tiles
- **WHEN** each tile is generated and saved
- **THEN** the system uses autoreleasepool to release memory before processing the next tile

#### Scenario: Respect 12MP limit per tile
- **WHEN** a grid cell would result in a tile larger than 12 megapixels
- **THEN** the system scales down the final tile to respect the 12MP maximum

---

### Requirement: Multi-Image Support in Grids
The system SHALL allow users to add multiple different source images and arrange them freely across grid cells.

#### Scenario: Add multiple images to library
- **WHEN** user taps "Add Photos" in grid mode
- **THEN** the system opens PhotosPicker allowing multiple selection

#### Scenario: Image library panel display
- **WHEN** user has added 5 images to the grid session
- **THEN** the bottom panel displays all 5 images as draggable thumbnails

#### Scenario: Use single image across entire grid
- **WHEN** user drags one image to fill all cells in a 3x3 grid
- **THEN** the system creates a large split image effect across 9 posts

#### Scenario: Mix of multiple images in one grid
- **WHEN** user places 3 different images in various cells of a 3x3 grid
- **THEN** each image is independently scalable and positionable in its assigned cells

---

### Requirement: Navigation Between Grid and Border Modes
The system SHALL provide clear navigation between the existing single-photo border mode and the new freeform grid mode.

#### Scenario: Access grid mode from main screen
- **WHEN** user is on ContentView and taps "Freeform Grid" button
- **THEN** the system navigates to GridEditingView with empty grid state

#### Scenario: Return to main screen from grid mode
- **WHEN** user taps back button or swipes back in GridEditingView
- **THEN** the system returns to ContentView and clears grid session data

#### Scenario: Modes are independent
- **WHEN** user switches from border mode to grid mode
- **THEN** the system does not carry over border settings or selected images to grid mode

---

### Requirement: Grid Mode Localization
The system SHALL provide English and Traditional Chinese translations for all grid-related UI text.

#### Scenario: Grid mode labels in English
- **WHEN** device language is set to English
- **THEN** grid UI displays "Freeform Grid", "Choose Layout", "Export Grid", etc.

#### Scenario: Grid mode labels in Chinese
- **WHEN** device language is set to Traditional Chinese (zh-Hant)
- **THEN** grid UI displays "自由網格", "選擇佈局", "匯出網格", etc.

#### Scenario: Grid dimension labels
- **WHEN** layout picker is displayed
- **THEN** dimensions are shown as "2×2 Grid" (EN) or "2×2 網格" (zh-Hant)

---

### Requirement: Emoji Overlay Support
The system SHALL allow users to add emoji overlays to individual grid cells for creative expression.

#### Scenario: Add emoji to cell
- **WHEN** user taps a grid cell and selects emoji from picker
- **THEN** the selected emoji appears centered on that cell

#### Scenario: Multiple emoji per cell
- **WHEN** user adds a second emoji to a cell that already has one
- **THEN** the system replaces the existing emoji with the new one (single emoji per cell)

#### Scenario: Remove emoji from cell
- **WHEN** user taps the emoji on a cell and selects "Remove"
- **THEN** the system clears the emoji from that cell

#### Scenario: Emoji persists during grid editing
- **WHEN** user adds emoji to a cell and then switches grid dimensions
- **THEN** the emoji is preserved if the cell still exists in new layout

#### Scenario: Emoji appears in exported tiles
- **WHEN** grid with emoji overlays is exported
- **THEN** each tile includes the emoji rendered at appropriate size and position

---

### Requirement: Auto-Save Grid Sessions
The system SHALL automatically save grid editing sessions to prevent data loss if the app closes unexpectedly.

#### Scenario: Auto-save during editing
- **WHEN** user is editing a grid and makes changes (add image, move image, add emoji)
- **THEN** the system auto-saves the grid state every 3 seconds

#### Scenario: Restore previous session on app launch
- **WHEN** user opens grid mode after previous session was not exported
- **THEN** the system displays alert "Restore previous grid?" with "Yes" and "Discard" options

#### Scenario: Restore session includes all data
- **WHEN** user chooses to restore previous session
- **THEN** the system restores grid dimensions, placed images, emoji, and background color

#### Scenario: Clear auto-save after successful export
- **WHEN** user successfully exports grid tiles
- **THEN** the system clears the auto-saved session data

#### Scenario: Manual discard of auto-save
- **WHEN** user chooses "Discard" on restore prompt
- **THEN** the system clears the auto-saved session and starts fresh

---

### Requirement: Grid Layout Presets
The system SHALL allow users to save and load grid configurations as presets integrated with the existing preset system.

#### Scenario: Save current grid as preset
- **WHEN** user taps "Save as Preset" and enters name "Magazine Layout"
- **THEN** the system saves grid dimensions, cell assignments, and emoji as a reusable preset

#### Scenario: Load grid preset
- **WHEN** user opens Presets sheet in grid mode and taps "Magazine Layout"
- **THEN** the system applies the saved grid configuration (dimensions, cells, emoji)

#### Scenario: Grid presets appear separately from border presets
- **WHEN** user opens Presets sheet
- **THEN** the system displays preset filter: "Border Presets" and "Grid Presets"

#### Scenario: Delete grid preset
- **WHEN** user swipes left on a grid preset and taps "Delete"
- **THEN** the system removes the preset from saved list

#### Scenario: Preset includes background color
- **WHEN** user loads a grid preset with saved background color
- **THEN** the system applies the preset's background color to empty cells

