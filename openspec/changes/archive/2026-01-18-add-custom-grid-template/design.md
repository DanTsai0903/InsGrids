# DESIGN: Customizable N×M Grid Template

## Overview

This document outlines the technical design for allowing users to create custom grid templates with arbitrary row and column counts.

## Architecture

### Component Hierarchy

```
LayoutTemplateSelectView
├── Existing template cards
└── Custom Grid Card
    └── (On Tap) CustomGridInputSheet
        ├── Column Stepper (1-30)
        ├── Row Stepper (1-30)
        ├── Preview Grid
        └── Confirm Button → Generate Template → Navigate to Editor
```

### Data Flow

1. User taps "Custom Grid" card
2. `CustomGridInputSheet` presents with default 2×2
3. User adjusts steppers, preview updates in real-time
4. User taps "Create"
5. Call `LayoutTemplate.customGrid(rows:columns:)` to generate template
6. Return to `LayoutTemplateSelectView` with generated template
7. Proceed with photo selection as normal

## Implementation Details

### LayoutTemplate Extension

Add a static factory method:

```swift
extension LayoutTemplate {
    static func customGrid(rows: Int, columns: Int) -> LayoutTemplate {
        let id = "custom_\(columns)x\(rows)"
        let name = "\(columns)×\(rows) Grid"
        
        var slots: [LayoutSlotShape] = []
        let slotWidth = 1.0 / CGFloat(columns)
        let slotHeight = 1.0 / CGFloat(rows)
        
        for row in 0..<rows {
            for col in 0..<columns {
                let rect = CGRect(
                    x: CGFloat(col) * slotWidth,
                    y: CGFloat(row) * slotHeight,
                    width: slotWidth,
                    height: slotHeight
                )
                slots.append(.rectangle(rect))
            }
        }
        
        return LayoutTemplate(id: id, name: name, slots: slots)
    }
}
```

### CustomGridInputSheet

New SwiftUI view with:

**State**:
- `@State private var columns: Int = 2`
- `@State private var rows: Int = 2`
- `@Binding var isPresented: Bool`
- Callback closure to return generated template

**UI Elements**:
- `Stepper` for columns (range: 1...30)
- `Stepper` for rows (range: 1...30)
- Visual preview grid showing the grid structure
- "Create" button
- "Cancel" button

**Validation**:
- Total slots = rows × columns
- Max slots = 900 (30×30)
- UI should disable creation if constraints violated

### Template Card Design

Add to template picker:
- Special card with "+" icon or grid-with-sliders icon
- Label: "Custom Grid"
- Subtitle: "Choose your size"
- Different visual treatment to distinguish from fixed templates

## UI/UX Considerations

### Preview Grid

Show a miniature visual representation of the grid:
- Small rectangles in a grid pattern
- Updates live as steppers change
- Helps users visualize before creating

### Input Constraints

- Min: 1×1 (1 slot) - Same as selecting a single slot template
- Max: 30×30 (900 slots) - Supports complex layouts
- Default: 2×2 (4 slots) - Reasonable starting point

### Discoverability

- Place "Custom Grid" card prominently (possibly first or last in picker)
- Use distinct visual styling
- Add icon that suggests customization

## Edge Cases

1. **1×1 Grid**: Valid but equivalent to freeform mode with one photo
2. **Large Grids (20×20+)**: May be cramped on smaller screens; consider warning users
3. **Aspect Ratio Interaction**: Grid should adapt to different aspect ratios (1:1, 4:5, etc.)
4. **Performance**: Large grids should use thumbnail-based rendering for acceptable performance

## Testing Strategy

- Unit test `customGrid()` function with various inputs
- UI test template picker → custom grid flow
- Manual test different grid sizes with real photos
- Test interaction with existing features (spacing, borders, draggable lines)

## Localization

New strings needed:
- `"template.customGrid"` = "Custom Grid"
- `"template.customGrid.subtitle"` = "Choose your size"
- `"customGrid.columns"` = "Columns"
- `"customGrid.rows"` = "Rows"
- `"customGrid.create"` = "Create Grid"
- `"customGrid.cancel"` = "Cancel"

Both English and Traditional Chinese.
