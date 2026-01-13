# DESIGN: Layout Feature Architecture

## Architecture
The feature follows MVVM pattern used in `InstaBorderApp`.

### ViewModels
- **`LayoutEditorViewModel`**:
    - Manages `LayoutConfiguration`.
    - Handles image loading and processing.
    - Generates final image for export using `ImageRenderer` or `UIGraphicsImageRenderer`.

### Layout System
The system treats each photo slot as a distinct geometric object (Shape).
- `LayoutTemplate` defines a list of `LayoutSlotShape`s (Rectangles or Polygons).
- **Generalized Spacing Algorithm**: Instead of hardcoding spacing weights, the system automatically detects internal edges (shared between slots).
    - `edgeInsets(for:innerSpacing:)` calculates weights dynamically.
    - **Weight Formula**: `weight = (totalGaps / slotCount) / internalEdgeCount`
    - This ensures that all slots shrink by the exact same total area, and all gaps between photos are identical in size, regardless of the template configuration.
- `LayoutSlotView` renders these shapes, handling:
    - Path generation with corner radius and calculated edge insets.
    - Image masking (clipping).
    - Gestures (Pan/Pinch) for individual photo manipulation.

### Models
```swift
enum LayoutSlotShape {
    case rectangle(CGRect) // Normalized
    case polygon(points: [CGPoint]) // Normalized points forming a closed shape
}

struct LayoutTemplate {
    let id: String
    let slots: [LayoutSlotShape]
}
struct LayoutPhoto: Identifiable {
    let id = UUID()
    var image: UIImage
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
}
```

### Persistence
`LayoutConfiguration` should be `Codable` to support Presets in the future (optional but good practice).
