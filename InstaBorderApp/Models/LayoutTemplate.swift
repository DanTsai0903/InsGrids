import SwiftUI

// MARK: - Layout Slot Shape
enum LayoutSlotShape {
    case rectangle(CGRect) // Normalized coordinates (0-1)
    case polygon(points: [CGPoint]) // Normalized points forming a closed shape
    
    /// Returns the bounding rect of the shape
    var boundingRect: CGRect {
        switch self {
        case .rectangle(let rect):
            return rect
        case .polygon(let points):
            guard !points.isEmpty else { return .zero }
            let minX = points.map { $0.x }.min() ?? 0
            let maxX = points.map { $0.x }.max() ?? 1
            let minY = points.map { $0.y }.min() ?? 0
            let maxY = points.map { $0.y }.max() ?? 1
            return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        }
    }
    
    /// Creates a Path for this shape in the given size with edge insets and corner radius
    /// - Parameters:
    ///   - sharedPointIndices: For polygons, indices of points shared with other slots.
    ///     Only shared points move inward; non-shared (anchor) points stay fixed.
    func path(in size: CGSize, edgeInsets: EdgeInsets, cornerRadius: CGFloat, sharedPointIndices: Set<Int>? = nil) -> Path {
        switch self {
        case .rectangle(let rect):
            let scaledRect = CGRect(
                x: rect.origin.x * size.width,
                y: rect.origin.y * size.height,
                width: rect.width * size.width,
                height: rect.height * size.height
            )

            let insetRect = CGRect(
                x: scaledRect.origin.x + edgeInsets.leading,
                y: scaledRect.origin.y + edgeInsets.top,
                width: scaledRect.width - edgeInsets.leading - edgeInsets.trailing,
                height: scaledRect.height - edgeInsets.top - edgeInsets.bottom
            )

            return Path(roundedRect: insetRect, cornerRadius: cornerRadius)

        case .polygon(let points):
            guard points.count >= 3 else { return Path() }

            // Scale points to actual size
            let scaledPoints = points.map { point in
                CGPoint(x: point.x * size.width, y: point.y * size.height)
            }

            // For polygons, apply uniform inset based on average of edge insets
            let avgInset = (edgeInsets.top + edgeInsets.leading + edgeInsets.bottom + edgeInsets.trailing) / 4
            let insetPoints = insetPolygon(points: scaledPoints, inset: avgInset, sharedIndices: sharedPointIndices)

            return createRoundedPolygonPath(points: insetPoints, cornerRadius: cornerRadius)
        }
    }
    
    /// Legacy method for backward compatibility
    func path(in size: CGSize, inset: CGFloat, cornerRadius: CGFloat) -> Path {
        let edgeInsets = EdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        return path(in: size, edgeInsets: edgeInsets, cornerRadius: cornerRadius)
    }
    
    /// Insets a polygon using edge-based parallel offset to preserve angles.
    /// - Interior edges (both endpoints movable) are shifted inward parallel to themselves
    /// - Boundary edges (at least one fixed endpoint) stay in place
    /// - New vertices are computed as intersections of adjacent edges
    /// - Parameters:
    ///   - sharedIndices: Indices of points that can move. If nil, all points move (legacy behavior).
    private func insetPolygon(points: [CGPoint], inset: CGFloat, sharedIndices: Set<Int>?) -> [CGPoint] {
        guard points.count >= 3, inset > 0 else { return points }

        let n = points.count
        let movable = sharedIndices ?? Set(0..<n)

        // Determine which edges are interior (should move) vs boundary (stay fixed)
        // An edge from point i to point (i+1) is interior if BOTH endpoints are movable
        var edgeOffsets: [CGFloat] = Array(repeating: 0, count: n)
        for i in 0..<n {
            let nextIdx = (i + 1) % n
            let isInterior = movable.contains(i) && movable.contains(nextIdx)
            edgeOffsets[i] = isInterior ? inset : 0
        }

        // For each edge, compute the offset line (moved parallel inward)
        // Edge i goes from points[i] to points[(i+1) % n]
        struct OffsetLine {
            let point: CGPoint  // A point on the line
            let direction: CGPoint  // Unit direction vector along the edge
        }

        var offsetLines: [OffsetLine] = []
        for i in 0..<n {
            let p1 = points[i]
            let p2 = points[(i + 1) % n]

            // Edge direction
            let dx = p2.x - p1.x
            let dy = p2.y - p1.y
            let len = sqrt(dx * dx + dy * dy)
            guard len > 0.0001 else {
                offsetLines.append(OffsetLine(point: p1, direction: CGPoint(x: 1, y: 0)))
                continue
            }
            let dir = CGPoint(x: dx / len, y: dy / len)

            // Inward normal (perpendicular, pointing into the polygon)
            // For clockwise winding, inward is (-dy, dx); for counter-clockwise, it's (dy, -dx)
            // We'll use (-dir.y, dir.x) which points to the left of the direction
            let normal = CGPoint(x: -dir.y, y: dir.x)

            // Offset the edge by moving a point on it along the normal
            let offset = edgeOffsets[i]
            let offsetPoint = CGPoint(x: p1.x + normal.x * offset, y: p1.y + normal.y * offset)

            offsetLines.append(OffsetLine(point: offsetPoint, direction: dir))
        }

        // Compute new vertices as intersections of adjacent offset lines
        var newPoints: [CGPoint] = []
        for i in 0..<n {
            let prevEdgeIdx = (i - 1 + n) % n
            let line1 = offsetLines[prevEdgeIdx]  // Edge ending at vertex i
            let line2 = offsetLines[i]            // Edge starting at vertex i

            if let intersection = lineIntersection(
                p1: line1.point, d1: line1.direction,
                p2: line2.point, d2: line2.direction
            ) {
                newPoints.append(intersection)
            } else {
                // Lines are parallel, keep original point
                newPoints.append(points[i])
            }
        }

        return newPoints
    }

    /// Find intersection of two lines defined by point + direction
    private func lineIntersection(p1: CGPoint, d1: CGPoint, p2: CGPoint, d2: CGPoint) -> CGPoint? {
        // Line 1: p1 + t * d1
        // Line 2: p2 + s * d2
        // Solve: p1 + t * d1 = p2 + s * d2

        let cross = d1.x * d2.y - d1.y * d2.x
        guard abs(cross) > 0.0001 else { return nil }  // Lines are parallel

        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let t = (dx * d2.y - dy * d2.x) / cross

        return CGPoint(x: p1.x + t * d1.x, y: p1.y + t * d1.y)
    }
    
    /// Creates a path with rounded corners for a polygon
    private func createRoundedPolygonPath(points: [CGPoint], cornerRadius: CGFloat) -> Path {
        guard points.count >= 3 else { return Path() }
        guard cornerRadius > 0 else {
            var path = Path()
            path.move(to: points[0])
            for i in 1..<points.count {
                path.addLine(to: points[i])
            }
            path.closeSubpath()
            return path
        }
        
        var path = Path()
        let n = points.count
        
        for i in 0..<n {
            let curr = points[i]
            let next = points[(i + 1) % n]
            let prev = points[(i - 1 + n) % n]
            
            let v1 = CGPoint(x: curr.x - prev.x, y: curr.y - prev.y).normalized()
            let v2 = CGPoint(x: next.x - curr.x, y: next.y - curr.y).normalized()
            
            let startPoint = CGPoint(
                x: curr.x - v1.x * cornerRadius,
                y: curr.y - v1.y * cornerRadius
            )
            let endPoint = CGPoint(
                x: curr.x + v2.x * cornerRadius,
                y: curr.y + v2.y * cornerRadius
            )
            
            if i == 0 {
                path.move(to: startPoint)
            } else {
                path.addLine(to: startPoint)
            }
            
            path.addQuadCurve(to: endPoint, control: curr)
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Layout Template
struct LayoutTemplate: Identifiable {
    let id: String
    let name: String
    let slots: [LayoutSlotShape]
    /// For each slot, indices of polygon points that should stay fixed (anchored).
    /// Points NOT in this set will move inward when inner spacing is adjusted.
    /// For rectangle slots, this is ignored (rectangles use edge-based insets).
    let fixedPointIndices: [[Int]]

    var slotCount: Int {
        slots.count
    }

    init(id: String, name: String, slots: [LayoutSlotShape], fixedPointIndices: [[Int]]? = nil) {
        self.id = id
        self.name = name
        self.slots = slots
        // Default: empty arrays (all points move, legacy behavior)
        self.fixedPointIndices = fixedPointIndices ?? Array(repeating: [], count: slots.count)
    }

    /// Returns the set of point indices that should move (not fixed) for a polygon slot.
    /// This is the inverse of fixedPointIndices - points that are NOT fixed should move.
    func movablePointIndices(for slotIndex: Int) -> Set<Int>? {
        guard slotIndex >= 0 && slotIndex < slots.count else { return nil }
        guard case .polygon(let points) = slots[slotIndex] else { return nil }

        let fixed = Set(fixedPointIndices[slotIndex])
        let allIndices = Set(0..<points.count)
        return allIndices.subtracting(fixed)
    }
    
    /// Calculate edge insets for a specific slot to create spacing between adjacent slots
    /// This method automatically detects which edges are shared with other slots and
    /// calculates the appropriate inset weights to ensure all slots shrink equally.
    func edgeInsets(for slotIndex: Int, innerSpacing: CGFloat) -> EdgeInsets {
        guard slotIndex >= 0 && slotIndex < slots.count else {
            return EdgeInsets()
        }
        
        let slot = slots[slotIndex]
        let bounds = slot.boundingRect
        
        // Check if this is a polygon slot
        let isPolygon: Bool
        switch slot {
        case .polygon: isPolygon = true
        case .rectangle: isPolygon = false
        }
        
        // Find which edges are internal (shared with another slot)
        var internalEdges: Set<Edge> = []
        let threshold: CGFloat = 0.001
        
        for (i, otherSlot) in slots.enumerated() {
            guard i != slotIndex else { continue }
            let otherBounds = otherSlot.boundingRect
            
            // Check if right edge of current touches left edge of other
            if abs(bounds.maxX - otherBounds.minX) < threshold &&
               bounds.minY < otherBounds.maxY && bounds.maxY > otherBounds.minY {
                internalEdges.insert(.trailing)
            }
            // Check if left edge of current touches right edge of other
            if abs(bounds.minX - otherBounds.maxX) < threshold &&
               bounds.minY < otherBounds.maxY && bounds.maxY > otherBounds.minY {
                internalEdges.insert(.leading)
            }
            // Check if bottom edge of current touches top edge of other
            if abs(bounds.maxY - otherBounds.minY) < threshold &&
               bounds.minX < otherBounds.maxX && bounds.maxX > otherBounds.minX {
                internalEdges.insert(.bottom)
            }
            // Check if top edge of current touches bottom edge of other
            if abs(bounds.minY - otherBounds.maxY) < threshold &&
               bounds.minX < otherBounds.maxX && bounds.maxX > otherBounds.minX {
                internalEdges.insert(.top)
            }
        }
        
        // For polygons without detected axis-aligned internal edges (e.g., diagonal splits),
        // apply uniform spacing to all edges based on the formula (slots-1)/slots
        if isPolygon && internalEdges.isEmpty && slots.count > 1 {
            let weight = CGFloat(slots.count - 1) / CGFloat(slots.count)
            let uniformInset = innerSpacing * weight
            return EdgeInsets(
                top: uniformInset,
                leading: uniformInset,
                bottom: uniformInset,
                trailing: uniformInset
            )
        }
        
        // Calculate the weight per edge for equal spacing
        // Goal: each slot shrinks equally AND each gap is equal
        let internalEdgeCount = internalEdges.count
        guard internalEdgeCount > 0 else {
            return EdgeInsets()
        }
        
        // Count total number of internal edges across all slots to estimate gaps
        let totalInternalEdges = slots.indices.reduce(0) { count, i in
            count + countInternalEdges(for: i)
        }
        // Each gap is shared by 2 slots' edges, so totalGaps = totalInternalEdges / 2
        let totalGaps = max(1, totalInternalEdges / 2)
        
        // Weight per slot = totalGaps / slotCount (each slot loses this much total)
        // Weight per edge = (totalGaps / slotCount) / internalEdgeCount
        let weightPerEdge = (CGFloat(totalGaps) / CGFloat(slots.count)) / CGFloat(internalEdgeCount)
        let edgeInset = innerSpacing * weightPerEdge
        
        return EdgeInsets(
            top: internalEdges.contains(.top) ? edgeInset : 0,
            leading: internalEdges.contains(.leading) ? edgeInset : 0,
            bottom: internalEdges.contains(.bottom) ? edgeInset : 0,
            trailing: internalEdges.contains(.trailing) ? edgeInset : 0
        )
    }
    
    /// Count internal edges for a slot
    private func countInternalEdges(for slotIndex: Int) -> Int {
        guard slotIndex >= 0 && slotIndex < slots.count else { return 0 }

        let bounds = slots[slotIndex].boundingRect
        let threshold: CGFloat = 0.001
        var count = 0

        for (i, otherSlot) in slots.enumerated() {
            guard i != slotIndex else { continue }
            let otherBounds = otherSlot.boundingRect

            if abs(bounds.maxX - otherBounds.minX) < threshold &&
               bounds.minY < otherBounds.maxY && bounds.maxY > otherBounds.minY { count += 1 }
            if abs(bounds.minX - otherBounds.maxX) < threshold &&
               bounds.minY < otherBounds.maxY && bounds.maxY > otherBounds.minY { count += 1 }
            if abs(bounds.maxY - otherBounds.minY) < threshold &&
               bounds.minX < otherBounds.maxX && bounds.maxX > otherBounds.minX { count += 1 }
            if abs(bounds.minY - otherBounds.maxY) < threshold &&
               bounds.minX < otherBounds.maxX && bounds.maxX > otherBounds.minX { count += 1 }
        }
        return count
    }
    
    // MARK: - Draggable Lines Detection
    
    /// Detect interior lines that can be dragged to resize adjacent slots.
    /// Lines pointing to slot corners are excluded to preserve slot shapes.
    func detectDraggableLines() -> [DraggableLine] {
        var lineSegments: [String: Set<Int>] = [:]  // lineKey -> affected slot indices
        let threshold: CGFloat = 0.001

        for (i, slot) in slots.enumerated() {
            let bounds = slot.boundingRect

            // Check each slot's edges against other slots
            for (j, otherSlot) in slots.enumerated() {
                guard j > i else { continue }  // Avoid duplicates
                let otherBounds = otherSlot.boundingRect

                // Check for horizontal shared edge (vertical divider)
                // Right edge of slot i touches left edge of slot j
                if abs(bounds.maxX - otherBounds.minX) < threshold &&
                   bounds.minY < otherBounds.maxY && bounds.maxY > otherBounds.minY {
                    let position = bounds.maxX
                    let lineKey = "v\(String(format: "%.4f", position))"

                    // Check if line points to corner
                    let startY = max(bounds.minY, otherBounds.minY)
                    let endY = min(bounds.maxY, otherBounds.maxY)
                    let startPoint = CGPoint(x: position, y: startY)
                    let endPoint = CGPoint(x: position, y: endY)

                    if !DraggableLine.pointsToCorner(startPoint: startPoint, endPoint: endPoint, slots: slots) {
                        // Accumulate affected slot indices for this line position
                        if lineSegments[lineKey] == nil {
                            lineSegments[lineKey] = []
                        }
                        lineSegments[lineKey]?.insert(i)
                        lineSegments[lineKey]?.insert(j)
                    }
                }

                // Check for vertical shared edge (horizontal divider)
                // Bottom edge of slot i touches top edge of slot j
                if abs(bounds.maxY - otherBounds.minY) < threshold &&
                   bounds.minX < otherBounds.maxX && bounds.maxX > otherBounds.minX {
                    let position = bounds.maxY
                    let lineKey = "h\(String(format: "%.4f", position))"

                    // Check if line points to corner
                    let startX = max(bounds.minX, otherBounds.minX)
                    let endX = min(bounds.maxX, otherBounds.maxX)
                    let startPoint = CGPoint(x: startX, y: position)
                    let endPoint = CGPoint(x: endX, y: position)

                    if !DraggableLine.pointsToCorner(startPoint: startPoint, endPoint: endPoint, slots: slots) {
                        // Accumulate affected slot indices for this line position
                        if lineSegments[lineKey] == nil {
                            lineSegments[lineKey] = []
                        }
                        lineSegments[lineKey]?.insert(i)
                        lineSegments[lineKey]?.insert(j)
                    }
                }
            }
        }

        // Create draggable lines from accumulated segments
        var lines: [DraggableLine] = []
        for (lineKey, affectedIndices) in lineSegments {
            guard lineKey.count > 1 else { continue }
            let orientationChar = lineKey.first!
            let position = CGFloat(Double(String(lineKey.dropFirst())) ?? 0)
            let orientation: LineOrientation = orientationChar == "h" ? .horizontal : .vertical

            lines.append(DraggableLine(
                id: lineKey,
                orientation: orientation,
                position: position,
                affectedSlotIndices: Array(affectedIndices).sorted()
            ))
        }

        return lines
    }
    
    /// Apply dimension overrides to slots and return modified slot shapes.
    func appliedSlots(with overrides: DimensionOverrides) -> [LayoutSlotShape] {
        guard !overrides.isEmpty else { return slots }
        
        var modifiedSlots = slots
        
        for (key, newPosition) in overrides.linePositions {
            guard key.count > 1 else { continue }
            let orientationChar = key.first!
            let originalPosition = CGFloat(Double(String(key.dropFirst())) ?? 0)
            
            let isHorizontal = orientationChar == "h"
            
            // Adjust affected slots
            for (i, slot) in modifiedSlots.enumerated() {
                switch slot {
                case .rectangle(var rect):
                    if isHorizontal {
                        // Horizontal line at originalPosition moved to newPosition
                        // Affects slots above (maxY == originalPosition) and below (minY == originalPosition)
                        if abs(rect.maxY - originalPosition) < 0.001 {
                            // Slot above the line - adjust height
                            let newHeight = newPosition - rect.minY
                            rect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: newHeight)
                            modifiedSlots[i] = .rectangle(rect)
                        } else if abs(rect.minY - originalPosition) < 0.001 {
                            // Slot below the line - adjust origin and height
                            let newHeight = rect.maxY - newPosition
                            rect = CGRect(x: rect.minX, y: newPosition, width: rect.width, height: newHeight)
                            modifiedSlots[i] = .rectangle(rect)
                        }
                    } else {
                        // Vertical line at originalPosition moved to newPosition
                        // Affects slots left (maxX == originalPosition) and right (minX == originalPosition)
                        if abs(rect.maxX - originalPosition) < 0.001 {
                            // Slot left of the line - adjust width
                            let newWidth = newPosition - rect.minX
                            rect = CGRect(x: rect.minX, y: rect.minY, width: newWidth, height: rect.height)
                            modifiedSlots[i] = .rectangle(rect)
                        } else if abs(rect.minX - originalPosition) < 0.001 {
                            // Slot right of the line - adjust origin and width
                            let newWidth = rect.maxX - newPosition
                            rect = CGRect(x: newPosition, y: rect.minY, width: newWidth, height: rect.height)
                            modifiedSlots[i] = .rectangle(rect)
                        }
                    }
                case .polygon:
                    // Polygons are not resizable via draggable lines
                    continue
                }
            }
        }
        
        return modifiedSlots
    }

}

// MARK: - Predefined Templates
extension LayoutTemplate {
    // 2-slot templates
    static let grid2x1 = LayoutTemplate(
        id: "grid2x1",
        name: "2 Horizontal",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 0.5, height: 1)),
            .rectangle(CGRect(x: 0.5, y: 0, width: 0.5, height: 1))
        ]
    )
    
    static let grid1x2 = LayoutTemplate(
        id: "grid1x2",
        name: "2 Vertical",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 1, height: 0.5)),
            .rectangle(CGRect(x: 0, y: 0.5, width: 1, height: 0.5))
        ]
    )
    
    static let diagonal2 = LayoutTemplate(
        id: "diagonal2",
        name: "Diagonal Split",
        slots: [
            // Top-left triangle: (0,0) top-left, (1,0) top-right, (0,1) bottom-left
            .polygon(points: [
                CGPoint(x: 0, y: 0),  // index 0 - FIXED (top-left corner)
                CGPoint(x: 1, y: 0),  // index 1 - moves (on diagonal)
                CGPoint(x: 0, y: 1)   // index 2 - moves (on diagonal)
            ]),
            // Bottom-right triangle: (1,0) top-right, (1,1) bottom-right, (0,1) bottom-left
            .polygon(points: [
                CGPoint(x: 1, y: 0),  // index 0 - moves (on diagonal)
                CGPoint(x: 1, y: 1),  // index 1 - FIXED (bottom-right corner)
                CGPoint(x: 0, y: 1)   // index 2 - moves (on diagonal)
            ])
        ],
        fixedPointIndices: [
            [0],  // Slot 0: top-left corner (0,0) is fixed
            [1]   // Slot 1: bottom-right corner (1,1) is fixed
        ]
    )
    
    // 3-slot templates
    static let grid3x1 = LayoutTemplate(
        id: "grid3x1",
        name: "3 Horizontal",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 1.0/3.0, height: 1)),
            .rectangle(CGRect(x: 1.0/3.0, y: 0, width: 1.0/3.0, height: 1)),
            .rectangle(CGRect(x: 2.0/3.0, y: 0, width: 1.0/3.0, height: 1))
        ]
    )
    
    static let grid1x3 = LayoutTemplate(
        id: "grid1x3",
        name: "3 Vertical",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 1, height: 1.0/3.0)),
            .rectangle(CGRect(x: 0, y: 1.0/3.0, width: 1, height: 1.0/3.0)),
            .rectangle(CGRect(x: 0, y: 2.0/3.0, width: 1, height: 1.0/3.0))
        ]
    )

    static let leftVert2Right1 = LayoutTemplate(
        id: "leftVert2Right1",
        name: "Left 2 Vertical + Right 1",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0, y: 0.5, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0.5, y: 0, width: 0.5, height: 1))
        ]
    )

    static let left1RightVert2 = LayoutTemplate(
        id: "left1RightVert2",
        name: "Left 1 + Right 2 Vertical",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 0.5, height: 1)),
            .rectangle(CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5))
        ]
    )

    static let top1BottomHoriz2 = LayoutTemplate(
        id: "top1BottomHoriz2",
        name: "Top 1 + Bottom 2 Horizontal",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 1, height: 0.5)),
            .rectangle(CGRect(x: 0, y: 0.5, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5))
        ]
    )

    static let topHoriz2Bottom1 = LayoutTemplate(
        id: "topHoriz2Bottom1",
        name: "Top 2 Horizontal + Bottom 1",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0, y: 0.5, width: 1, height: 0.5))
        ]
    )

    // 4-slot templates
    static let grid2x2 = LayoutTemplate(
        id: "grid2x2",
        name: "2x2 Grid",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0, y: 0.5, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5))
        ]
    )

    static let top1Bottom3Horiz = LayoutTemplate(
        id: "top1Bottom3Horiz",
        name: "Top 1 + Bottom 3 Horizontal",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 1, height: 0.6)),
            .rectangle(CGRect(x: 0, y: 0.6, width: 1.0/3.0, height: 0.4)),
            .rectangle(CGRect(x: 1.0/3.0, y: 0.6, width: 1.0/3.0, height: 0.4)),
            .rectangle(CGRect(x: 2.0/3.0, y: 0.6, width: 1.0/3.0, height: 0.4))
        ]
    )

    static let left1Right3Mixed = LayoutTemplate(
        id: "left1Right3Mixed",
        name: "Left 1 + Right 3 Mixed",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 0.5, height: 1)),
            .rectangle(CGRect(x: 0.5, y: 0, width: 0.5, height: 0.4)),
            .rectangle(CGRect(x: 0.5, y: 0.4, width: 0.25, height: 0.6)),
            .rectangle(CGRect(x: 0.75, y: 0.4, width: 0.25, height: 0.6))
        ]
    )

    static let left3VertRight1 = LayoutTemplate(
        id: "left3VertRight1",
        name: "Left 3 Vertical + Right 1",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 0.33, height: 1.0/3.0)),
            .rectangle(CGRect(x: 0, y: 1.0/3.0, width: 0.33, height: 1.0/3.0)),
            .rectangle(CGRect(x: 0, y: 2.0/3.0, width: 0.33, height: 1.0/3.0)),
            .rectangle(CGRect(x: 0.33, y: 0, width: 0.67, height: 1))
        ]
    )

    static let left2NarrowRight2Wide = LayoutTemplate(
        id: "left2NarrowRight2Wide",
        name: "Left 2 Narrow + Right 2 Wide",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 0.25, height: 0.5)),
            .rectangle(CGRect(x: 0, y: 0.5, width: 0.25, height: 0.5)),
            .rectangle(CGRect(x: 0.25, y: 0, width: 0.375, height: 1)),
            .rectangle(CGRect(x: 0.625, y: 0, width: 0.375, height: 1))
        ]
    )

    static let asymmetric2x2 = LayoutTemplate(
        id: "asymmetric2x2",
        name: "Asymmetric 2x2",
        slots: [
            .rectangle(CGRect(x: 0, y: 0, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0, y: 0.5, width: 0.5, height: 0.5)),
            .rectangle(CGRect(x: 0.5, y: 0, width: 0.5, height: 0.35)),
            .rectangle(CGRect(x: 0.5, y: 0.35, width: 0.5, height: 0.65))
        ]
    )

    static let allTemplates: [LayoutTemplate] = [
        grid2x1, grid1x2, diagonal2,
        grid3x1, grid1x3, leftVert2Right1, left1RightVert2, top1BottomHoriz2, topHoriz2Bottom1,
        grid2x2, top1Bottom3Horiz, left1Right3Mixed, left3VertRight1, left2NarrowRight2Wide, asymmetric2x2
    ]
    
    static func templates(withSlotCount count: Int) -> [LayoutTemplate] {
        allTemplates.filter { $0.slotCount == count }
    }
}

// MARK: - CGPoint Extension
extension CGPoint {
    func normalized() -> CGPoint {
        let length = sqrt(x * x + y * y)
        guard length > 0 else { return CGPoint(x: 0, y: 0) }
        return CGPoint(x: x / length, y: y / length)
    }
}
