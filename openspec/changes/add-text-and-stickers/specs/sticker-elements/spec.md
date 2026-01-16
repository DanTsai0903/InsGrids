## ADDED Requirements

### Requirement: Sticker Element Placement
The system SHALL allow users to place emoji and SF Symbol icons as sticker elements on the canvas.

#### Scenario: Open sticker picker
- **WHEN** user taps "Add Sticker" button in toolbar
- **THEN** the system displays sticker picker sheet with tabs: Emoji, Stickers

#### Scenario: Place emoji sticker
- **WHEN** user selects "🎉" emoji from sticker picker
- **THEN** the system places emoji sticker at canvas center

#### Scenario: Place SF Symbol sticker
- **WHEN** user selects "heart.fill" icon from Stickers tab
- **THEN** the system places icon sticker at canvas center with default color

#### Scenario: Browse icon categories
- **WHEN** user taps "Shapes & Symbols" category in Stickers tab
- **THEN** the system displays SF Symbols filtered to shapes category (circle.fill, square.fill, triangle.fill, etc.)

#### Scenario: Search for specific icon
- **WHEN** user types "star" in icon search field
- **THEN** the system displays all SF Symbols matching "star" (star.fill, star.circle, etc.)

#### Scenario: Multiple stickers on canvas
- **WHEN** user adds 5 different stickers (mix of emoji and icons) to canvas
- **THEN** each sticker maintains independent position, scale, rotation, and appearance

#### Scenario: Emoji picker displays categories
- **WHEN** user opens Emoji tab in sticker picker
- **THEN** the system displays emoji categories: Smileys, Hearts, Celebrations, Stars, Gestures, Food, Animals, Flowers

---

### Requirement: Sticker Element Transform Interactions
The system SHALL allow users to position, scale, and rotate sticker elements using gesture controls.

#### Scenario: Move sticker element
- **WHEN** user drags a sticker element across canvas
- **THEN** the system updates sticker position following finger movement

#### Scenario: Scale sticker element
- **WHEN** user performs pinch gesture on sticker element
- **THEN** the system scales sticker uniformly maintaining aspect ratio

#### Scenario: Rotate sticker element
- **WHEN** user performs two-finger rotation gesture on sticker element
- **THEN** the system rotates sticker around its center point

#### Scenario: Snap sticker to canvas edges
- **WHEN** user drags sticker near canvas edge (within 10pt)
- **THEN** the system snaps sticker position to edge alignment with haptic feedback

#### Scenario: Minimum and maximum sticker scale
- **WHEN** user pinches sticker very small or very large
- **THEN** the system constrains sticker scale between 0.3× and 4.0× to prevent unusable sizes

---

### Requirement: Sticker Element Selection and Actions
The system SHALL provide selection and action controls for sticker elements on the canvas.

#### Scenario: Select sticker element
- **WHEN** user long-presses a sticker element
- **THEN** the system highlights sticker element and displays action buttons: Delete, Bring to Front, Send to Back

#### Scenario: Delete sticker element via action button
- **WHEN** user taps "Delete" button while sticker element is selected
- **THEN** the system removes sticker element from canvas and adds action to undo stack

#### Scenario: Deselect sticker element
- **WHEN** user taps empty canvas area while sticker element is selected
- **THEN** the system clears selection and hides action buttons

#### Scenario: Bring sticker element to front
- **WHEN** user selects sticker element and taps "Bring to Front" button
- **THEN** the system moves element to end of array, rendering it on top of all other elements

#### Scenario: Send sticker element to back
- **WHEN** user selects sticker element and taps "Send to Back" button
- **THEN** the system moves element to start of array, rendering it behind all other elements

---

### Requirement: Sticker Element Persistence
The system SHALL save and restore sticker elements in auto-save sessions and grid presets.

#### Scenario: Auto-save includes sticker elements
- **WHEN** user adds emoji sticker "🌟" and SF Symbol "heart.fill" to canvas
- **THEN** auto-save serializes sticker type (emoji/icon), content, color, position, scale, rotation to disk

#### Scenario: Restore session with sticker elements
- **WHEN** user reopens app and restores previous session containing stickers
- **THEN** the system recreates sticker elements with exact type, content, color, position, scale, rotation

#### Scenario: Grid preset saves stickers
- **WHEN** user saves current grid as preset containing sticker elements
- **THEN** preset serializes all sticker data with transforms

#### Scenario: Load grid preset with stickers
- **WHEN** user loads grid preset containing stickers
- **THEN** the system recreates complete composition with stickers at saved positions

---

### Requirement: Sticker Element High-Resolution Export
The system SHALL render sticker elements at appropriate resolution during tile export matching image quality.

#### Scenario: Export sticker element in tile
- **WHEN** tile export encounters sticker element within tile bounds
- **THEN** the system renders sticker at tile resolution maintaining aspect ratio and quality

#### Scenario: Sticker spans multiple tiles
- **WHEN** large sticker element spans 2 tiles
- **THEN** each tile renders its portion of sticker seamlessly aligned at tile boundaries

#### Scenario: Sticker Z-order preserved in export
- **WHEN** canvas has image with sticker overlay
- **THEN** tile export renders layers in correct order maintaining sticker position in element array

#### Scenario: SF Symbol color exported correctly
- **WHEN** user changes SF Symbol sticker color to blue
- **THEN** tile export renders icon in specified blue color

#### Scenario: Emoji rendered at high resolution
- **WHEN** tile export renders emoji sticker
- **THEN** the system uses high-resolution emoji rendering (NSAttributedString with large font size) to prevent pixelation

---

### Requirement: Sticker Element Undo/Redo Support
The system SHALL integrate sticker operations into the existing undo/redo stack.

#### Scenario: Undo add sticker element
- **WHEN** user adds sticker element and taps undo button
- **THEN** the system removes sticker element from canvas and restores previous state

#### Scenario: Undo delete sticker element
- **WHEN** user deletes sticker element and taps undo button
- **THEN** the system restores element with exact position and transforms

#### Scenario: Undo sticker transform
- **WHEN** user moves, scales, or rotates sticker element and taps undo button
- **THEN** the system restores element to previous position, scale, and rotation

#### Scenario: Undo sticker Z-order change
- **WHEN** user brings sticker to front or sends to back and taps undo button
- **THEN** the system restores previous element Z-order

#### Scenario: Redo sticker operations
- **WHEN** user performs undo then taps redo button
- **THEN** the system reapplies the undone operation (add, delete, transform, Z-order change)

---

### Requirement: Sticker Element Localization
The system SHALL provide English and Traditional Chinese translations for all sticker element UI.

#### Scenario: Sticker picker UI in English
- **WHEN** device language is English
- **THEN** sticker picker displays: "Add Sticker", "Emoji", "Stickers", "Search Stickers"

#### Scenario: Sticker picker UI in Chinese
- **WHEN** device language is Traditional Chinese (zh-Hant)
- **THEN** sticker picker displays: "新增貼紙", "表情符號", "貼紙", "搜尋貼紙"

#### Scenario: Sticker action buttons in English
- **WHEN** device language is English and user long-presses sticker element
- **THEN** action buttons display: "Delete", "Bring to Front", "Send to Back"

#### Scenario: Sticker action buttons in Chinese
- **WHEN** device language is Traditional Chinese and user long-presses sticker element
- **THEN** action buttons display: "刪除", "移到最上層", "移到最下層"

---

## MODIFIED Requirements

### Requirement: Emoji Overlay Support
Users SHALL add emoji, SF Symbols, and custom stickers to the canvas as independent elements with full transform capabilities.

**Note**: This requirement is being replaced by the new comprehensive sticker system (Requirement: Sticker Element Placement). The previous implementation limited emoji to one per cell and did not support SF Symbols or transform gestures.

#### Scenario: Legacy behavior removed
- **WHEN** user opens grid created with old emoji-per-cell system
- **THEN** the system migrates emoji to new sticker element model at cell center positions

#### Scenario: Stickers not limited by grid cells
- **WHEN** user places sticker on canvas
- **THEN** sticker can be positioned anywhere on canvas, not restricted to cell boundaries

#### Scenario: Multiple stickers per cell area
- **WHEN** user places 3 stickers in same cell region
- **THEN** the system allows overlapping stickers with independent positions and Z-order
