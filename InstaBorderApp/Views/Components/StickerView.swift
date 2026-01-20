import SwiftUI
import UIKit

/// View for rendering a sticker element on the canvas
struct StickerView: View {
    let element: StickerElement
    let isSelected: Bool
    var onDelete: (() -> Void)? = nil

    /// Calculate the actual frame size for custom stickers based on image aspect ratio
    private var customStickerSize: CGSize {
        guard element.type == .customSticker,
              let uiImage = UIImage(named: element.content) else {
            return CGSize(width: element.size, height: element.size)
        }

        let imageAspect = uiImage.size.width / uiImage.size.height

        if imageAspect > 1 {
            // Wider than tall - width is the constraining dimension
            return CGSize(width: element.size, height: element.size / imageAspect)
        } else {
            // Taller than wide - height is the constraining dimension
            return CGSize(width: element.size * imageAspect, height: element.size)
        }
    }

    var body: some View {
        stickerContent
            .overlay(selectionOverlay)
            .scaleEffect(element.scale)
            .rotationEffect(element.rotation)
    }

    @ViewBuilder
    private var stickerContent: some View {
        switch element.type {
        case .emoji:
            // Legacy support for backward compatibility
            Text(element.content)
                .font(.system(size: element.size))
        case .sfSymbol:
            Image(systemName: element.content)
                .font(.system(size: element.size))
                .foregroundColor(element.color ?? .primary)
        case .customSticker:
            // Custom sticker from Assets.xcassets with proper aspect ratio
            let size = customStickerSize
            Image(element.content)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width, height: size.height)
        }
    }

    @ViewBuilder
    private var selectionOverlay: some View {
        if isSelected {
            GeometryReader { geometry in
                let padding: CGFloat = 8
                let deleteButtonSize: CGFloat = 24
                // Scale-adjusted button size to keep it visually consistent
                let adjustedButtonSize = deleteButtonSize / element.scale

                ZStack(alignment: .topTrailing) {
                    // Selection rectangle that fits the sticker
                    RoundedRectangle(cornerRadius: 4 / element.scale)
                        .stroke(Color.blue, lineWidth: 2 / element.scale)
                        .frame(width: geometry.size.width + padding * 2 / element.scale,
                               height: geometry.size.height + padding * 2 / element.scale)
                        .position(x: geometry.size.width / 2,
                                  y: geometry.size.height / 2)

                    // Delete button at top-right corner
                    if let onDelete = onDelete {
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            onDelete()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: adjustedButtonSize, height: adjustedButtonSize)
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: adjustedButtonSize))
                                    .foregroundColor(.red)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 2 / element.scale, x: 0, y: 1 / element.scale)
                        }
                        .position(x: geometry.size.width + padding / element.scale,
                                  y: -padding / element.scale)
                    }
                }
            }
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
    var onDelete: (() -> Void)? = nil

    @State private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var gestureRotationRaw: Angle = .zero
    @State private var hasBeenBroughtToFront = false

    var body: some View {
        StickerView(element: element, isSelected: isSelected, onDelete: onDelete)
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
                    onUpdateScale(max(0.3, newScale))
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
