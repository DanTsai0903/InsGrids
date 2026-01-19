# PROPOSAL: Add Customizable N×M Grid Template

## Motivation

Users currently have a fixed set of predefined layout templates (2×1, 2×2, 3×1, etc.). However, they may want to create custom grids with arbitrary dimensions that aren't available in the preset templates. For example, a user might want a 4×3 grid (12 slots) or a 5×2 grid (10 slots) for specific use cases.

This feature will add a "Custom Grid" option that allows users to specify the number of rows and columns they want, dynamically generating a uniform rectangular grid layout.

## Detailed Design

### User Flow

1. User opens Layout Editor and taps the template picker
2. Among the predefined templates, there's a special "Custom Grid" option
3. When tapped, a dialog appears asking for:
   - Number of columns (n): 1-30
   - Number of rows (m): 1-30
4. User inputs dimensions and confirms
5. A uniform n×m grid template is dynamically generated
6. User proceeds to add photos to the generated grid

### Data Model Changes

**`LayoutTemplate.swift`**:
- Add a static function `customGrid(rows: Int, columns: Int) -> LayoutTemplate` that generates a template on-demand
- The generated template will have `id` format: `"custom_\(columns)x\(rows)"` (e.g., `"custom_4x3"`)
- The template will create equal-sized rectangular slots arranged in a grid

### UI Components

**Grid Dimension Input Sheet**:
- SwiftUI sheet/dialog with:
  - Two `Stepper` controls (or number pickers)
  - Live preview showing the grid structure
  - Confirm/Cancel buttons
- Constraints:
  - Minimum: 1×1
  - Maximum: 30×30 (900 slots)
  - Default: 2×2

**Template Selection Integration**:
- Add "Custom Grid" as a special card in the template picker
- Visual indicator (e.g., icon with adjustable grid or "+" symbol)
- Tap behavior different from regular templates

### Technical Implementation

**Grid Generation Algorithm**:
```
For a grid with c columns and r rows:
- Slot width = 1.0 / c
- Slot height = 1.0 / r
- For each row i (0 to r-1):
  - For each column j (0 to c-1):
    - Create rectangle at (j * width, i * height, width, height)
```

**Draggable Lines**:
- Custom grids will automatically support draggable lines since they're rectangular grids
- The existing `detectDraggableLines()` function will work without modification

## Alternatives Considered

1. **Add ALL possible combinations as presets**: Would bloat the template picker UI and make it harder to find desired layouts
2. **Freeform slot addition**: Too complex for users who just want a simple grid
3. **Text input for dimensions**: Less user-friendly than steppers/pickers

## Success Criteria

- Users can create grids with any n×m dimension (within limits)
- Generated grids work seamlessly with existing features (spacing, borders, draggable lines)
- UI is intuitive and discoverable
