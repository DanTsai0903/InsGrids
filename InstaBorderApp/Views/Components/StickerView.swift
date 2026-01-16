import SwiftUI

/// View for rendering a sticker element on the canvas
struct StickerView: View {
    let element: StickerElement
    let isSelected: Bool
    
    var body: some View {
        Group {
            switch element.type {
            case .emoji:
                Text(element.content)
                    .font(.system(size: element.size))
            case .sfSymbol:
                Image(systemName: element.content)
                    .font(.system(size: element.size))
                    .foregroundColor(element.color ?? .primary)
            }
        }
        .scaleEffect(element.scale)
        .rotationEffect(element.rotation)
        .overlay(selectionOverlay)
    }
    
    @ViewBuilder
    private var selectionOverlay: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.blue, lineWidth: 2)
                .padding(-8)
        }
    }
}

/// Canvas-integrated sticker element view with gesture support
struct StickerElementView: View {
    @Binding var element: StickerElement
    let canvasSize: CGSize
    let isSelected: Bool
    var onSelect: () -> Void
    var onManipulate: () -> Void
    var onUpdatePosition: (CGPoint) -> Void
    var onUpdateScale: (CGFloat) -> Void
    var onUpdateRotation: (Angle) -> Void
    
    @State private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var gestureRotationRaw: Angle = .zero
    @State private var hasBeenBroughtToFront = false
    
    var body: some View {
        StickerView(element: element, isSelected: isSelected)
            .scaleEffect(gestureScale)  // Apply live gesture scale
            .rotationEffect(gestureRotationRaw)  // Apply live gesture rotation
            .position(
                x: element.position.x + dragOffset.width,
                y: element.position.y + dragOffset.height
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onSelect()
                    }
            )
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        if !hasBeenBroughtToFront {
                            onManipulate()
                            hasBeenBroughtToFront = true
                        }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let newPosition = CGPoint(
                            x: element.position.x + value.translation.width,
                            y: element.position.y + value.translation.height
                        )
                        onUpdatePosition(newPosition)
                        dragOffset = .zero
                        hasBeenBroughtToFront = false
                    }
                    .simultaneously(with: transformGesture)
            )
    }
    
    private var transformGesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture(minimumScaleDelta: 0)
                .updating($gestureScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    let newScale = element.scale * value
                    onUpdateScale(max(0.3, min(4.0, newScale)))
                },
            RotationGesture(minimumAngleDelta: .zero)
                .onChanged { value in
                    gestureRotationRaw = value
                }
                .onEnded { value in
                    let rawRotation = element.rotation + value
                    let (snappedRotation, _) = SnapHelper.snapRotation(rawRotation)
                    onUpdateRotation(snappedRotation)
                    gestureRotationRaw = .zero
                }
        )
    }
}
