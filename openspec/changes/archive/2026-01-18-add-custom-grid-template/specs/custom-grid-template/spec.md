## ADDED Requirements

### Requirement: Grid Dimension Input

The system MUST provide a UI for users to specify custom grid dimensions.

**Acceptance Criteria:**
- Input support for columns (1-30)
- Input support for rows (1-30)
- Visual preview of grid structure
- Default dimensions: 2×2

#### Scenario: User Creates 3×4 Grid

**Given** the user is in the Layout Editor template selection

**When** the user taps "Custom Grid"

**Then** a sheet appears with steppers for columns and rows

**And** columns defaults to 2

**And** rows defaults to 2

**When** the user adjusts columns to 3

**And** rows to 4

**Then** the preview shows a 3×4 grid structure

**When** the user taps "Create Grid"

**Then** a 3×4 uniform rectangular grid template is generated

**And** the user proceeds to photo selection with 12 slots

---

### Requirement: Dynamic Template Generation

The system MUST generate uniform rectangular grid templates on-demand based on user-specified dimensions.

**Acceptance Criteria:**
- Each slot has equal width and height
- Slots fill the entire normalized space (0-1)
- Template ID follows format: `custom_{columns}x{rows}`
- Generated templates support all existing features (spacing, borders, draggable lines)

#### Scenario: Generated 2×3 Grid Has Correct Layout

**Given** a user requests a 2×3 grid (2 columns, 3 rows)

**When** the template is generated

**Then** there are 6 slots total

**And** each slot has width = 0.5 (1.0 / 2)

**And** each slot has height ≈ 0.333 (1.0 / 3)

**And** slot positions cover all combinations:
- (0, 0), (0.5, 0)
- (0, 0.333), (0.5, 0.333)
- (0, 0.667), (0.5, 0.667)

**And** draggable lines are automatically detected between adjacent slots

---

### Requirement: Input Validation

The system MUST enforce constraints on custom grid dimensions.

**Acceptance Criteria:**
- Minimum dimensions: 1×1
- Maximum dimensions: 30×30
- Maximum total slots: 900
- Input controls prevent invalid values

#### Scenario: User Cannot Exceed Maximum Dimensions

**Given** the custom grid input sheet is open

**When** the user attempts to increase columns beyond 30

**Then** the stepper is disabled at 30

**When** the user attempts to increase rows beyond 30

**Then** the stepper is disabled at 30

#### Scenario: Minimum Dimensions Are Enforced

**Given** the custom grid input sheet is open

**When** the user attempts to decrease columns below 1

**Then** the stepper is disabled at 1

**When** the user attempts to decrease rows below 1

**Then** the stepper is disabled at 1

---

### Requirement: Template Picker Integration

The Custom Grid option MUST be discoverable in the template picker.

**Acceptance Criteria:**
- "Custom Grid" card appears in template selection view
- Visual distinction from fixed templates (icon, styling)
- Tapping opens dimension input sheet
- Localized labels in English and Traditional Chinese

#### Scenario: Custom Grid Card Is Discoverable

**Given** the user opens the Layout Editor

**When** the user views the template picker

**Then** a "Custom Grid" card is visible

**And** it has a distinct icon (e.g., grid with "+" or adjustment symbol)

**And** the label reads "Custom Grid" (localized)

**When** the user taps the "Custom Grid" card

**Then** the dimension input sheet appears

---

### Requirement: Feature Compatibility

Custom grids MUST work seamlessly with all existing layout features.

**Acceptance Criteria:**
- Inner spacing adjustment works correctly
- Outer border width works correctly
- Corner radius works correctly
- Draggable lines are automatically detected
- All aspect ratios are supported (1:1, 4:5, 16:9, 9:16)

#### Scenario: Custom Grid Supports Draggable Lines

**Given** a user creates a 3×2 custom grid

**When** the template is rendered in the editor

**Then** 2 vertical draggable lines appear (between columns)

**And** 1 horizontal draggable line appears (between rows)

**When** the user drags a line

**Then** adjacent slots resize accordingly

#### Scenario: Custom Grid Respects Inner Spacing

**Given** a user has a 2×2 custom grid

**When** the user adjusts inner spacing to 20

**Then** all 4 slots shrink equally

**And** gaps between slots are uniform
