import SwiftUI

/// Overlay that displays drag handles on interior lines for resizing slots
struct DraggableLinesOverlay: View {
    @ObservedObject var viewModel: LayoutEditorViewModel
    let contentSize: CGSize
    let activeSlotIndex: Int?
    
    /// Size of the drag handle touch area
    private let handleSize: CGFloat = 66
    /// Size of the visible handle icon background
    private let handleIconSize: CGFloat = 42
    
    var body: some View {
        ZStack {
            ForEach(viewModel.draggableLines) { line in
                if shouldShowHandle(for: line) {
                    DragLineHandle(
                        line: line,
                        currentPosition: viewModel.currentLinePosition(line),
                        contentSize: contentSize,
                        handleSize: handleSize,
                        handleIconSize: handleIconSize,
                        activeSlotIndex: activeSlotIndex,
                        slots: viewModel.appliedSlots,
                        onDragStart: {
                            viewModel.saveSnapshot()
                        },
                        onDragChanged: { newPosition in
                            viewModel.updateLinePosition(line, to: newPosition)
                        }
                    )
                }
            }
        }
    }
    
    /// Check if handle should be shown for this line
    /// Handles appear only when a slot adjacent to this line is active
    private func shouldShowHandle(for line: DraggableLine) -> Bool {
        guard let activeIndex = activeSlotIndex else { return false }
        return line.affectedSlotIndices.contains(activeIndex)
    }
}

/// Individual drag handle for a single interior line
struct DragLineHandle: View {
    let line: DraggableLine
    let currentPosition: CGFloat
    let contentSize: CGSize
    let handleSize: CGFloat
    let handleIconSize: CGFloat
    let activeSlotIndex: Int?
    let slots: [LayoutSlotShape]
    let onDragStart: () -> Void
    let onDragChanged: (CGFloat) -> Void

    @State private var isDragging = false

    var body: some View {
        let center = handleCenter

        ZStack {
            // Handle background
            Circle()
                .fill(Color.blue.opacity(0.9))
                .frame(width: handleIconSize, height: handleIconSize)

            // Handle icon
            Image(systemName: line.orientation == .horizontal ? "arrow.up.and.down" : "arrow.left.and.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(isDragging ? 1.2 : 1.0)
        .animation(.spring(response: 0.3), value: isDragging)
        .position(center)
        .gesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        onDragStart()
                    }

                    let newPosition: CGFloat
                    if line.orientation == .horizontal {
                        // Horizontal line moves vertically
                        newPosition = value.location.y / contentSize.height
                    } else {
                        // Vertical line moves horizontally
                        newPosition = value.location.x / contentSize.width
                    }
                    onDragChanged(newPosition)
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
    }

    /// Calculate the center point for the handle based on the active slot's edge
    private var handleCenter: CGPoint {
        guard let activeIndex = activeSlotIndex,
              activeIndex < slots.count,
              line.affectedSlotIndices.contains(activeIndex) else {
            // Fallback to canvas center if no active slot
            return defaultHandleCenter
        }

        let activeSlotBounds = slots[activeIndex].boundingRect

        if line.orientation == .horizontal {
            // Horizontal line: find the middle X of the edge within the active slot's bounds
            let edgeStartX = activeSlotBounds.minX
            let edgeEndX = activeSlotBounds.maxX
            let midX = (edgeStartX + edgeEndX) / 2

            return CGPoint(
                x: midX * contentSize.width,
                y: currentPosition * contentSize.height
            )
        } else {
            // Vertical line: find the middle Y of the edge within the active slot's bounds
            let edgeStartY = activeSlotBounds.minY
            let edgeEndY = activeSlotBounds.maxY
            let midY = (edgeStartY + edgeEndY) / 2

            return CGPoint(
                x: currentPosition * contentSize.width,
                y: midY * contentSize.height
            )
        }
    }

    /// Default handle position (center of entire canvas) used as fallback
    private var defaultHandleCenter: CGPoint {
        if line.orientation == .horizontal {
            return CGPoint(
                x: contentSize.width / 2,
                y: currentPosition * contentSize.height
            )
        } else {
            return CGPoint(
                x: currentPosition * contentSize.width,
                y: contentSize.height / 2
            )
        }
    }
}

#Preview {
    DraggableLinesOverlay(
        viewModel: LayoutEditorViewModel(
            template: .grid1x2,
            images: []
        ),
        contentSize: CGSize(width: 300, height: 400),
        activeSlotIndex: 0
    )
    .background(Color.gray.opacity(0.3))
}
