import SwiftUI

/// View for rendering a text element on the canvas
struct TextView: View {
    let element: TextElement
    let isSelected: Bool
    
    var body: some View {
        Group {
            if let bgColor = element.backgroundColor {
                Text(element.text)
                    .font(fontForElement(element))
                    .foregroundColor(element.color)
                    .multilineTextAlignment(element.alignment)
                    .padding(8)
                    .background(bgColor.opacity(element.backgroundOpacity))
                    .cornerRadius(4)
            } else {
                Text(element.text)
                    .font(fontForElement(element))
                    .foregroundColor(element.color)
                    .multilineTextAlignment(element.alignment)
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
                .padding(-4)
        }
    }
    
    private func fontForElement(_ element: TextElement) -> Font {
        let weight = element.resolvedFontWeight()
        let size = element.fontSize

        // Handle SF Pro system font specially
        if element.fontFamily == "SF Pro" {
            return .system(size: size, weight: weight.weight)
        }

        // Use custom font PostScript name
        return .custom(weight.postScriptName, size: size)
    }
}

/// Canvas-integrated text element view with gesture support
struct TextElementView: View {
    @Binding var element: TextElement
    let canvasSize: CGSize
    let isSelected: Bool
    var onSelect: () -> Void
    var onManipulate: () -> Void
    var onDoubleTap: () -> Void
    var onUpdatePosition: (CGPoint) -> Void
    var onUpdateScale: (CGFloat) -> Void
    var onUpdateRotation: (Angle) -> Void
    
    @State private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var gestureRotationRaw: Angle = .zero
    @State private var hasBeenBroughtToFront = false
    
    var body: some View {
        TextView(element: element, isSelected: isSelected)
            .scaleEffect(gestureScale)  // Apply live gesture scale
            .rotationEffect(gestureRotationRaw)  // Apply live gesture rotation
            .position(
                x: element.position.x + dragOffset.width,
                y: element.position.y + dragOffset.height
            )
            .simultaneousGesture(
                TapGesture(count: 1)
                    .onEnded {
                        onDoubleTap()  // Open editor on single tap
                    }
            )
            .onTapGesture {
                onSelect()
                onDoubleTap()  // Open editor on single tap
            }
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded {
                        onDoubleTap()
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onDoubleTap()  // Open text editor for re-editing
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
