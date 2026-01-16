## ADDED Requirements

### Requirement: Text Element Creation and Editing
The system SHALL allow users to add text elements to the canvas with full formatting and editing capabilities.

#### Scenario: Add new text element to canvas
- **WHEN** user taps "Add Text" button in toolbar
- **THEN** the system displays text editor sheet with default text "Tap to edit"

####Scenario: Edit text content
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
- **WHEN** user double-taps existing text element on canvas
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

### Requirement: Text Element Selection and Actions
The system SHALL provide selection and action controls for text elements on the canvas.

#### Scenario: Select text element
- **WHEN** user long-presses a text element
- **THEN** the system highlights text element and displays action buttons: Edit, Delete, Bring to Front, Send to Back

#### Scenario: Delete text element via action button
- **WHEN** user taps "Delete" button while text element is selected
- **THEN** the system removes text element from canvas and adds action to undo stack

#### Scenario: Edit text element via action button
- **WHEN** user taps "Edit" button while text element is selected
- **THEN** the system opens text editor sheet with current text and formatting

#### Scenario: Deselect text element
- **WHEN** user taps empty canvas area while text element is selected
- **THEN** the system clears selection and hides action buttons

#### Scenario: Bring text element to front
- **WHEN** user selects text element and taps "Bring to Front" button
- **THEN** the system moves element to end of array, rendering it on top of all other elements

#### Scenario: Send text element to back
- **WHEN** user selects text element and taps "Send to Back" button
- **THEN** the system moves element to start of array, rendering it behind all other elements

---

### Requirement: Text Element Persistence
The system SHALL save and restore text elements in auto-save sessions and grid presets.

#### Scenario: Auto-save includes text elements
- **WHEN** user adds text element "Summer 2024" with Georgia font, 36pt size, red color
- **THEN** auto-save serializes text content, font, size, color, position, scale, rotation to disk

#### Scenario: Restore session with text elements
- **WHEN** user reopens app and restores previous session containing text elements
- **THEN** the system recreates text elements with exact content, font, size, color, position, scale, rotation

#### Scenario: Grid preset saves text elements
- **WHEN** user saves current grid as preset containing text elements
- **THEN** preset serializes all text data with formatting and transforms

#### Scenario: Load grid preset with text elements
- **WHEN** user loads grid preset containing text elements
- **THEN** the system recreates complete composition with text elements at saved positions

---

### Requirement: Text Element High-Resolution Export
The system SHALL render text elements at appropriate resolution during tile export matching image quality.

#### Scenario: Export text element in tile
- **WHEN** tile export encounters text element within tile bounds
- **THEN** the system renders text at tile resolution with correct font, size, color, position, scale, rotation

#### Scenario: Text spans multiple tiles
- **WHEN** large text element spans 4 tiles in 2×2 grid
- **THEN** each tile renders its portion of text element seamlessly aligned at tile boundaries

#### Scenario: Text element Z-order preserved in export
- **WHEN** canvas has image with text overlay
- **THEN** tile export renders layers in correct order maintaining text position in element array

#### Scenario: Text with background exported correctly
- **WHEN** text element has solid or semi-transparent background
- **THEN** tile export renders background rectangle behind text at correct opacity

---

### Requirement: Text Element Undo/Redo Support
The system SHALL integrate text operations into the existing undo/redo stack.

#### Scenario: Undo add text element
- **WHEN** user adds text element and taps undo button
- **THEN** the system removes text element from canvas and restores previous state

#### Scenario: Undo edit text element
- **WHEN** user edits text content and taps undo button
- **THEN** the system restores previous text content and formatting

#### Scenario: Undo delete text element
- **WHEN** user deletes text element and taps undo button
- **THEN** the system restores element with exact position, formatting, and transforms

#### Scenario: Undo text transform
- **WHEN** user moves, scales, or rotates text element and taps undo button
- **THEN** the system restores element to previous position, scale, and rotation

#### Scenario: Undo text Z-order change
- **WHEN** user brings text element to front or sends to back and taps undo button
- **THEN** the system restores previous element Z-order

#### Scenario: Redo text operations
- **WHEN** user performs undo then taps redo button
- **THEN** the system reapplies the undone operation (add, edit, delete, transform, Z-order change)

---

### Requirement: Text Element Localization
The system SHALL provide English and Traditional Chinese translations for all text element UI.

#### Scenario: Text editor UI in English
- **WHEN** device language is English
- **THEN** text editor displays: "Add Text", "Edit Text", "Font", "Size", "Color", "Alignment", "Background", "Done"

#### Scenario: Text editor UI in Chinese
- **WHEN** device language is Traditional Chinese (zh-Hant)
- **THEN** text editor displays: "新增文字", "編輯文字", "字型", "大小", "顏色", "對齊", "背景", "完成"

#### Scenario: Text action buttons in English
- **WHEN** device language is English and user long-presses text element
- **THEN** action buttons display: "Edit", "Delete", "Bring to Front", "Send to Back"

#### Scenario: Text action buttons in Chinese
- **WHEN** device language is Traditional Chinese and user long-presses text element
- **THEN** action buttons display: "編輯", "刪除", "移到最上層", "移到最下層"
