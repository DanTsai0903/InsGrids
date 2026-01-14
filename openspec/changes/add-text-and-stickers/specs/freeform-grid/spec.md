## ADDED Requirements

### Requirement: Text Element Creation and Editing
The system SHALL allow users to add text elements to the canvas with full formatting and editing capabilities.

#### Scenario: Add new text element to canvas
- **WHEN** user taps "Add Text" button in toolbar
- **THEN** the system displays text editor sheet with default text "Tap to edit"

#### Scenario: Edit text content
- **WHEN** user types "Summer Vibes" in text editor and confirms
- **THEN** the system places text element at canvas center with entered content

#### Scenario: Change font
- **WHEN** user selects "Georgia" from font picker while editing text
- **THEN** the text element displays with Georgia font

#### Scenario: Adjust font size
- **WHEN** user moves font size slider to 48pt
- **THEN** the text element renders at 48pt size

#### Scenario: Change text color
- **WHEN** user selects red color from color picker
- **THEN** the text element displays in red color

#### Scenario: Set text alignment
- **WHEN** user taps "Center" alignment button
- **THEN** the text element centers its content (affects multi-line text)

#### Scenario: Add text background
- **WHEN** user selects "Solid" background and chooses white color
- **THEN** the text element displays with opaque white background behind text

#### Scenario: Add semi-transparent background
- **WHEN** user selects "Semi-transparent" background
- **THEN** the text element displays with 50% opacity background behind text

#### Scenario: Edit existing text element
- **WHEN** user taps existing text element on canvas
- **THEN** the system opens text editor sheet with current text and formatting

#### Scenario: Multiple text elements
- **WHEN** user adds 3 different text elements to canvas
- **THEN** each text element maintains independent content, font, size, color, and position

---

### Requirement: Text Element Transform Interactions
The system SHALL allow users to position, scale, and rotate text elements using gesture controls matching image element behavior.

#### Scenario: Move text element
- **WHEN** user drags a text element across canvas
- **THEN** the system updates text element position following finger movement

#### Scenario: Scale text element
- **WHEN** user performs pinch gesture on text element
- **THEN** the system scales text element uniformly (both width and height)

#### Scenario: Rotate text element
- **WHEN** user performs two-finger rotation gesture on text element
- **THEN** the system rotates text element around its center point

#### Scenario: Snap text to canvas edges
- **WHEN** user drags text element near canvas edge (within 10pt)
- **THEN** the system snaps text position to edge alignment with haptic feedback

#### Scenario: Snap text rotation to cardinal angles
- **WHEN** user rotates text element near 0°, 90°, 180°, or 270° (within 5° threshold)
- **THEN** the system snaps rotation to exact angle with haptic feedback

---

### Requirement: Sticker Element Placement
The system SHALL allow users to place emoji and SF Symbol icons as sticker elements on the canvas.

#### Scenario: Open sticker picker
- **WHEN** user taps "Add Sticker" button in toolbar
- **THEN** the system displays sticker picker sheet with tabs: Emoji, Icons

#### Scenario: Place emoji sticker
- **WHEN** user selects "🎉" emoji from sticker picker
- **THEN** the system places emoji sticker at canvas center

#### Scenario: Place SF Symbol sticker
- **WHEN** user selects "heart.fill" icon from Icons tab
- **THEN** the system places icon sticker at canvas center with default color

#### Scenario: Browse icon categories
- **WHEN** user taps "Shapes & Symbols" category in Icons tab
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

### Requirement: Canvas Element Selection and Actions
The system SHALL provide consistent selection and action controls for all canvas element types (images, text, stickers).

#### Scenario: Select text element
- **WHEN** user long-presses a text element
- **THEN** the system highlights text element and displays action buttons: Edit, Delete

#### Scenario: Select sticker element
- **WHEN** user long-presses a sticker element
- **THEN** the system highlights sticker element and displays action buttons: Delete

#### Scenario: Delete text element via action button
- **WHEN** user taps "Delete" button while text element is selected
- **THEN** the system removes text element from canvas and adds action to undo stack

#### Scenario: Delete sticker element via action button
- **WHEN** user taps "Delete" button while sticker element is selected
- **THEN** the system removes sticker element from canvas and adds action to undo stack

#### Scenario: Edit text element via action button
- **WHEN** user taps "Edit" button while text element is selected
- **THEN** the system opens text editor sheet with current text and formatting

#### Scenario: Deselect element
- **WHEN** user taps empty canvas area while element is selected
- **THEN** the system clears selection and hides action buttons

---

### Requirement: Canvas Element Z-Order Management
The system SHALL allow users to control the layering order of canvas elements for composition.

#### Scenario: Elements render in array order
- **WHEN** canvas contains 3 images, 2 text elements, and 1 sticker
- **THEN** the system renders elements in array order with last element on top (overlapping earlier elements)

#### Scenario: Bring element to front
- **WHEN** user selects a text element and taps "Bring to Front" button
- **THEN** the system moves element to end of array, rendering it on top of all other elements

#### Scenario: Send element to back
- **WHEN** user selects a sticker element and taps "Send to Back" button
- **THEN** the system moves element to start of array, rendering it behind all other elements

#### Scenario: Z-order preserved in auto-save
- **WHEN** user arranges elements with specific layering and app auto-saves
- **THEN** restored session maintains exact element order (Z-order)

#### Scenario: Newly added elements appear on top
- **WHEN** user adds new text or sticker element to canvas
- **THEN** the system places element at end of array, rendering on top of existing elements

---

### Requirement: Text and Sticker Element Persistence
The system SHALL save and restore text and sticker elements in auto-save sessions and grid presets.

#### Scenario: Auto-save includes text elements
- **WHEN** user adds text element "Summer 2024" with Georgia font, 36pt size, red color
- **THEN** auto-save serializes text content, font, size, color, position, scale, rotation to disk

#### Scenario: Auto-save includes sticker elements
- **WHEN** user adds emoji sticker "🌟" and SF Symbol "heart.fill" to canvas
- **THEN** auto-save serializes sticker type (emoji/icon), content, color, position, scale, rotation to disk

#### Scenario: Restore session with text elements
- **WHEN** user reopens app and restores previous session containing text elements
- **THEN** the system recreates text elements with exact content, font, size, color, position, scale, rotation

#### Scenario: Restore session with sticker elements
- **WHEN** user reopens app and restores previous session containing stickers
- **THEN** the system recreates sticker elements with exact type, content, color, position, scale, rotation

#### Scenario: Grid preset saves text and stickers
- **WHEN** user saves current grid as preset containing text and sticker elements
- **THEN** preset serializes all element data (images, text, stickers) with formatting and transforms

#### Scenario: Load grid preset with text and stickers
- **WHEN** user loads grid preset containing text and stickers
- **THEN** the system recreates complete composition with all element types at saved positions

---

### Requirement: Text and Sticker High-Resolution Export
The system SHALL render text and sticker elements at appropriate resolution during tile export matching image quality.

#### Scenario: Export text element in tile
- **WHEN** tile export encounters text element within tile bounds
- **THEN** the system renders text at tile resolution with correct font, size, color, position, scale, rotation

#### Scenario: Export sticker element in tile
- **WHEN** tile export encounters sticker element within tile bounds
- **THEN** the system renders sticker at tile resolution maintaining aspect ratio and quality

#### Scenario: Text spans multiple tiles
- **WHEN** large text element spans 4 tiles in 2x2 grid
- **THEN** each tile renders its portion of text element seamlessly aligned at tile boundaries

#### Scenario: Sticker spans multiple tiles
- **WHEN** large sticker element spans 2 tiles
- **THEN** each tile renders its portion of sticker seamlessly aligned at tile boundaries

#### Scenario: Element Z-order preserved in export
- **WHEN** canvas has image with text overlay and sticker on top
- **THEN** tile export renders layers in correct order: image (bottom), text (middle), sticker (top)

#### Scenario: Text with background exported correctly
- **WHEN** text element has solid or semi-transparent background
- **THEN** tile export renders background rectangle behind text at correct opacity

#### Scenario: SF Symbol color exported correctly
- **WHEN** user changes SF Symbol sticker color to blue
- **THEN** tile export renders icon in specified blue color

#### Scenario: Emoji rendered at high resolution
- **WHEN** tile export renders emoji sticker
- **THEN** the system uses high-resolution emoji rendering (NSAttributedString with large font size) to prevent pixelation

---

### Requirement: Text and Sticker Undo/Redo Support
The system SHALL integrate text and sticker operations into the existing undo/redo stack.

#### Scenario: Undo add text element
- **WHEN** user adds text element and taps undo button
- **THEN** the system removes text element from canvas and restores previous state

#### Scenario: Undo edit text element
- **WHEN** user edits text content and taps undo button
- **THEN** the system restores previous text content and formatting

#### Scenario: Undo add sticker element
- **WHEN** user adds sticker element and taps undo button
- **THEN** the system removes sticker element from canvas and restores previous state

#### Scenario: Undo delete element
- **WHEN** user deletes text or sticker element and taps undo button
- **THEN** the system restores element with exact position, formatting, and transforms

#### Scenario: Undo text transform
- **WHEN** user moves, scales, or rotates text element and taps undo button
- **THEN** the system restores element to previous position, scale, and rotation

#### Scenario: Undo sticker transform
- **WHEN** user moves, scales, or rotates sticker element and taps undo button
- **THEN** the system restores element to previous position, scale, and rotation

#### Scenario: Undo Z-order change
- **WHEN** user brings element to front or sends to back and taps undo button
- **THEN** the system restores previous element Z-order

#### Scenario: Redo text and sticker operations
- **WHEN** user performs undo then taps redo button
- **THEN** the system reapplies the undone operation (add, edit, delete, transform, Z-order change)

---

### Requirement: Text and Sticker Localization
The system SHALL provide English and Traditional Chinese translations for all text and sticker UI elements.

#### Scenario: Text editor UI in English
- **WHEN** device language is English
- **THEN** text editor displays: "Add Text", "Edit Text", "Font", "Size", "Color", "Alignment", "Background", "Done"

#### Scenario: Text editor UI in Chinese
- **WHEN** device language is Traditional Chinese (zh-Hant)
- **THEN** text editor displays: "新增文字", "編輯文字", "字型", "大小", "顏色", "對齊", "背景", "完成"

#### Scenario: Sticker picker UI in English
- **WHEN** device language is English
- **THEN** sticker picker displays: "Add Sticker", "Emoji", "Icons", "Search Icons"

#### Scenario: Sticker picker UI in Chinese
- **WHEN** device language is Traditional Chinese (zh-Hant)
- **THEN** sticker picker displays: "新增貼紙", "表情符號", "圖示", "搜尋圖示"

#### Scenario: Element action buttons in English
- **WHEN** device language is English and user long-presses element
- **THEN** action buttons display: "Edit", "Delete", "Bring to Front", "Send to Back"

#### Scenario: Element action buttons in Chinese
- **WHEN** device language is Traditional Chinese and user long-presses element
- **THEN** action buttons display: "編輯", "刪除", "移到最上層", "移到最下層"

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
