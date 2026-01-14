---
description: Add a new layout template to the Layout Editor feature.
---

**Overview**

Layout templates define the arrangement of photo slots in the Layout Editor. Templates use a normalized coordinate system (0-1) and support both rectangular and polygon shapes.

**Key Components:**
- `LayoutSlotShape`: Enum defining either `.rectangle(CGRect)` or `.polygon(points: [CGPoint])`
- `LayoutTemplate`: Struct containing template metadata and slot definitions
- Draggable lines: Automatically detected for rectangular grids

**Coordinate System:**
- Origin (0,0) is top-left
- All coordinates are normalized 0-1
- x: 0 = left edge, 1 = right edge
- y: 0 = top edge, 1 = bottom edge

---

## Steps

### 1. Define the Template

Open `InstaBorderApp/Models/LayoutTemplate.swift` and add a new static property.

**For Rectangle Templates:**

```swift
static let myTemplate = LayoutTemplate(
    id: "myTemplate",              // Unique identifier (used for persistence)
    name: "My Template",           // Display name shown in UI
    slots: [
        .rectangle(CGRect(x: 0, y: 0, width: 0.5, height: 1)),
        .rectangle(CGRect(x: 0.5, y: 0, width: 0.5, height: 1))
    ]
)
```

**For Polygon Templates:**

```swift
static let diagonal2 = LayoutTemplate(
    id: "diagonal2",
    name: "Diagonal Split",
    slots: [
        .polygon(points: [
            CGPoint(x: 0, y: 0),    // Top-left
            CGPoint(x: 1, y: 0),    // Top-right
            CGPoint(x: 0, y: 1)     // Bottom-left
        ]),
        .polygon(points: [
            CGPoint(x: 1, y: 0),    // Top-right
            CGPoint(x: 1, y: 1),    // Bottom-right
            CGPoint(x: 0, y: 1)     // Bottom-left
        ])
    ],
    fixedPointIndices: [
        [0],  // Slot 0: top-left corner (0,0) is fixed
        [1]   // Slot 1: bottom-right corner (1,1) is fixed
    ]
)
```

**Polygon Requirements:**
- Points must form a closed shape (minimum 3 points)
- List points in clockwise or counter-clockwise order
- Points are automatically connected in sequence

**Fixed Point Indices:**
- For polygons, specify which corner points should not move when inner spacing is applied
- This prevents triangles from becoming misshapen when spacing increases
- Use empty array `[]` to allow all points to move
- Rectangle templates can omit this parameter (it's ignored for rectangles)

### 2. Register the Template

Add your template to the `allTemplates` array in `LayoutTemplate.swift`:

```swift
static let allTemplates: [LayoutTemplate] = [
    grid2x1, grid1x2, diagonal2,
    grid3x1, grid1x3,
    grid2x2,
    myTemplate  // Add your new template here
]
```

**Order matters:** Templates appear in the UI in the order they're listed. Group templates by slot count for better UX.

### 3. Add Localization (Optional)

If using a localization key for the name:

**`en.lproj/Localizable.strings`:**
```
"template.myTemplate" = "My Template";
```

**`zh-Hant.lproj/Localizable.strings`:**
```
"template.myTemplate" = "我的模板";
```

### 4. Test the Template

1. Build and run: `xcodebuild -project InsGrids.xcodeproj -target InsGrids -configuration Debug -sdk iphonesimulator`
2. Open the Layout feature
3. Verify:
   - Template appears grouped by slot count
   - All slots render correctly
   - Photos can be added to each slot
   - Inner spacing works properly (test 0-30 range)
   - Drag handles appear on appropriate edges (rectangles only)
   - Outer border and corner radius work
   - Test all aspect ratios: 1:1, 4:5, 16:9, 9:16

---

## Draggable Lines System

**Automatically Supported:**
- Rectangular grids where slots share straight edges
- Lines are detected between adjacent slots

**Not Supported:**
- Polygon templates with diagonal edges
- Templates with non-rectangular geometry

**Detection Logic:**
- Horizontal lines: Bottom edge of one slot touches top edge of another
- Vertical lines: Right edge of one slot touches left edge of another
- Corner-pointing lines are excluded (preserves slot shapes)
- Line segments at the same position are merged across multiple slots

---

## Examples

### Simple 3-Column Grid

```swift
static let grid3x1 = LayoutTemplate(
    id: "grid3x1",
    name: "3 Horizontal",
    slots: [
        .rectangle(CGRect(x: 0, y: 0, width: 1.0/3.0, height: 1)),
        .rectangle(CGRect(x: 1.0/3.0, y: 0, width: 1.0/3.0, height: 1)),
        .rectangle(CGRect(x: 2.0/3.0, y: 0, width: 1.0/3.0, height: 1))
    ]
)
```

**Draggable Lines:** 2 vertical lines (at x=1/3 and x=2/3)

### L-Shape Layout

```swift
static let lShape = LayoutTemplate(
    id: "lShape",
    name: "L-Shape",
    slots: [
        .rectangle(CGRect(x: 0, y: 0, width: 0.5, height: 1)),     // Left half
        .rectangle(CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5)), // Top-right
        .rectangle(CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)) // Bottom-right
    ]
)
```

**Draggable Lines:** 2 lines (1 vertical at x=0.5, 1 horizontal at y=0.5 for right side only)

### Triangle Split (4 slots)

```swift
static let triangle4 = LayoutTemplate(
    id: "triangle4",
    name: "4 Triangles",
    slots: [
        .polygon(points: [
            CGPoint(x: 0.5, y: 0.5), // Center
            CGPoint(x: 0, y: 0),     // Top-left
            CGPoint(x: 1, y: 0)      // Top-right
        ]),
        .polygon(points: [
            CGPoint(x: 0.5, y: 0.5), // Center
            CGPoint(x: 1, y: 0),     // Top-right
            CGPoint(x: 1, y: 1)      // Bottom-right
        ]),
        .polygon(points: [
            CGPoint(x: 0.5, y: 0.5), // Center
            CGPoint(x: 1, y: 1),     // Bottom-right
            CGPoint(x: 0, y: 1)      // Bottom-left
        ]),
        .polygon(points: [
            CGPoint(x: 0.5, y: 0.5), // Center
            CGPoint(x: 0, y: 1),     // Bottom-left
            CGPoint(x: 0, y: 0)      // Top-left
        ])
    ],
    fixedPointIndices: [
        [1, 2],  // Slot 0: Fix corners
        [1, 2],  // Slot 1: Fix corners
        [1, 2],  // Slot 2: Fix corners
        [1, 2]   // Slot 3: Fix corners
    ]
)
```

**Draggable Lines:** None (diagonal edges point to center corner)

---

## Troubleshooting

**Slots not appearing:**
- Check coordinate values are between 0 and 1
- Verify rectangles don't have zero width or height
- Ensure polygon has at least 3 points

**Draggable lines not working:**
- Only rectangular grids support draggable lines
- Check that adjacent slots share edges (within 0.001 threshold)
- Verify lines don't point to slot corners

**Inner spacing looks wrong:**
- For polygons, adjust `fixedPointIndices` to preserve shape
- For rectangles, ensure edges align properly with neighbors

**Template not in UI:**
- Confirm template is added to `allTemplates` array
- Rebuild the app (clean build if necessary)

---

## Architecture Notes

**Auto-Detection:**
- Edge sharing detection uses 0.001 threshold for floating-point comparisons
- Draggable lines merge segments at the same position across multiple slots
- Inner spacing calculation automatically weights edges based on adjacency

**Dimension Overrides:**
- User adjustments are stored separately from template definitions
- Keys format: "h0.5" (horizontal at y=0.5) or "v0.5" (vertical at x=0.5)
- Applied in `LayoutTemplate.appliedSlots(with:)` method

**Constraints:**
- Minimum slot edge: 10% of canvas dimension (prevents unusable small slots)
- Templates are immutable; user edits create dimension overrides

---

## Best Practices

1. **Test with different aspect ratios:** Templates should work with 1:1, 4:5, 16:9, and 9:16
2. **Verify spacing:** Test with various inner spacing values (0-30)
3. **Check corner cases:** Ensure templates work with minimum and maximum border widths
4. **Performance:** Keep slot counts reasonable (2-9 slots tested)
5. **Naming:** Use clear, descriptive names that indicate the layout style
6. **ID uniqueness:** Never reuse template IDs (affects user data persistence)
