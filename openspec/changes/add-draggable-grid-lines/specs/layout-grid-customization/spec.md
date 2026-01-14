## ADDED Requirements

### Requirement: Slot Extend/Shorten via Interior Lines
The Layout Editor SHALL allow users to extend or shorten slots by dragging interior divider lines. Only the two slots sharing the interior line SHALL be affected; other slots remain unchanged.

#### Scenario: Extending a slot vertically
- **GIVEN** a layout template with slots stacked vertically (e.g., grid1x2)
- **WHEN** the user drags the horizontal interior line toward the adjacent slot
- **THEN** the target slot SHALL grow while the adjacent slot shrinks by the same amount
- **AND** other slots in the layout (if any) SHALL remain unchanged
- **AND** the layout canvas SHALL update in real-time

#### Scenario: Extending a slot horizontally
- **GIVEN** a layout template with slots arranged horizontally (e.g., grid2x1)
- **WHEN** the user drags the vertical interior line toward the adjacent slot
- **THEN** the target slot SHALL grow while the adjacent slot shrinks by the same amount
- **AND** other slots in the layout (if any) SHALL remain unchanged
- **AND** the layout canvas SHALL update in real-time

---

### Requirement: Non-Extendable Corner-Adjacent Slots
Slots whose interior lines point to at least one corner SHALL NOT be extendable or shortenable, to preserve slot shapes.

#### Scenario: Corner-adjacent slots remain fixed
- **GIVEN** a layout template where an interior line points to a slot corner (e.g., diagonal2 with triangular slots)
- **WHEN** the layout is displayed
- **THEN** no drag handles SHALL appear on that interior line
- **AND** the slot shapes SHALL remain fixed

---

### Requirement: Minimum Slot Size Constraint
The system SHALL enforce a minimum edge length of 10% of the canvas dimension for any slot edge when extending or shortening slots.

#### Scenario: Preventing slots from becoming too small
- **GIVEN** a user is extending a slot
- **WHEN** the extension would shrink an adjacent slot edge smaller than 10% of the canvas dimension
- **THEN** the drag position SHALL be clamped to maintain the minimum edge size
- **AND** the adjacent slot SHALL NOT become smaller than the minimum

---

### Requirement: Slot Size Persistence
Custom slot proportions (from extending/shortening) SHALL be persisted as part of the layout configuration.

#### Scenario: Saving and restoring custom slot sizes
- **GIVEN** a user has extended or shortened slots
- **WHEN** the layout is saved and later reopened
- **THEN** the custom slot sizes SHALL be restored exactly as configured

---

### Requirement: Visual Drag Handle Indicator
Drag handle indicators (↕ for horizontal lines, ↔ for vertical lines) SHALL appear on interior lines only when a slot is active (tapped) or the user is manipulating the photo in a slot (moving, zooming).

#### Scenario: Drag handle appears on slot tap
- **GIVEN** a layout template with extendable slots
- **WHEN** the user taps on a slot
- **THEN** drag handle icons SHALL appear on the interior lines adjacent to that slot
- **AND** the icon orientation SHALL match the drag direction

#### Scenario: Drag handle appears during photo manipulation
- **GIVEN** a layout template with extendable slots
- **WHEN** the user moves or zooms a photo within a slot
- **THEN** drag handle icons SHALL appear on the interior lines adjacent to that slot

#### Scenario: Drag handle hidden on tap outside
- **GIVEN** a slot is active with drag handles visible
- **WHEN** the user taps anywhere other than the active slot
- **THEN** the drag handle icons SHALL be hidden

#### Scenario: Drag handle hidden when another slot activated
- **GIVEN** a slot is active with drag handles visible
- **WHEN** the user taps on a different slot
- **THEN** the previous slot's drag handles SHALL be hidden
- **AND** the newly tapped slot's drag handles SHALL appear
