import SwiftUI

// MARK: - Draggable Line Orientation
enum LineOrientation: String, Codable {
    case horizontal  // Divides slots vertically (drag up/down)
    case vertical    // Divides slots horizontally (drag left/right)
}

// MARK: - Draggable Line
/// Represents an interior line between two adjacent slots that can be dragged to resize them.
struct DraggableLine: Identifiable, Equatable {
    let id: String
    let orientation: LineOrientation
    let position: CGFloat  // Normalized position (0-1)
    let affectedSlotIndices: [Int]  // Indices of the two slots this line separates
    
    /// The key used to store this line's position in DimensionOverrides
    var overrideKey: String {
        let prefix = orientation == .horizontal ? "h" : "v"
        return "\(prefix)\(String(format: "%.4f", position))"
    }
    
    /// Check if this line points to a corner (i.e., an endpoint is a slot corner)
    /// Lines pointing to corners are NOT draggable
    static func pointsToCorner(
        startPoint: CGPoint,
        endPoint: CGPoint,
        slots: [LayoutSlotShape]
    ) -> Bool {
        let threshold: CGFloat = 0.001
        
        for slot in slots {
            switch slot {
            case .polygon(let points):
                // Check if either endpoint matches any polygon corner
                for corner in points {
                    if (abs(startPoint.x - corner.x) < threshold && abs(startPoint.y - corner.y) < threshold) ||
                       (abs(endPoint.x - corner.x) < threshold && abs(endPoint.y - corner.y) < threshold) {
                        // Check if this corner is not on canvas boundary
                        let isOnBoundary = corner.x < threshold || corner.x > 1 - threshold ||
                                           corner.y < threshold || corner.y > 1 - threshold
                        if !isOnBoundary {
                            return true
                        }
                    }
                }
            case .rectangle:
                // Rectangle corners on interior would make them non-rectangular, skip
                continue
            }
        }
        return false
    }
}
