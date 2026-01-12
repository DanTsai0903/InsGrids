import SwiftUI

/// Represents an image placed on the freeform canvas
struct CanvasImage: Identifiable {
    var id = UUID()
    var image: UIImage
    
    // Transform properties
    var position: CGPoint = .zero  // Center position on canvas
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
}

/// Codable version of CanvasImage for persistence (Metadata only)
struct SavedCanvasImage: Codable {
    let id: UUID
    let positionX: CGFloat
    let positionY: CGFloat
    let scale: CGFloat
    let rotationDegrees: Double
    
    init(from canvasImage: CanvasImage) {
        self.id = canvasImage.id
        self.positionX = canvasImage.position.x
        self.positionY = canvasImage.position.y
        self.scale = canvasImage.scale
        self.rotationDegrees = canvasImage.rotation.degrees
    }
    
    // toCanvasImage will now be handled by ViewModel which knows where the images are stored
}

/// Freeform canvas where images can be placed and transformed freely
struct FreeformCanvasView: View {
    @Binding var images: [CanvasImage]
    @Binding var canvasScale: CGFloat
    @Binding var pendingDeleteImageId: UUID?
    let gridRows: Int
    let gridColumns: Int
    let backgroundColor: Color
    var onBringToFront: (UUID) -> Void
    var onDeleteImage: ((UUID) -> Void)? = nil
    var onCropImage: ((UUID) -> Void)? = nil
    var onImageManipulationStart: (() -> Void)? = nil
    
    // Canvas gesture states
    @GestureState private var gesturePinchScale: CGFloat = 1.0

    
    var body: some View {
        GeometryReader { geometry in
            let canvasSize = geometry.size
            let cellWidth = canvasSize.width / CGFloat(gridColumns)
            let cellHeight = cellWidth / (4.0 / 5.0)
            let gridHeight = cellHeight * CGFloat(gridRows)
            let effectiveScale = canvasScale * gesturePinchScale
            
            ZStack {
                // Full area background for gesture capture
                Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        pendingDeleteImageId = nil
                    }
                
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    canvasContent(
                        canvasSize: canvasSize,
                        gridHeight: gridHeight,
                        cellWidth: cellWidth,
                        cellHeight: cellHeight,
                        effectiveScale: effectiveScale
                    )
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { _ in
                            pendingDeleteImageId = nil
                        }
                )
                
                // Centered delete button overlay
                // Centered action buttons overlay (Delete & Crop)
                if let id = pendingDeleteImageId {
                    HStack(spacing: 40) {
                        // Crop Button
                        Button {
                            pendingDeleteImageId = nil
                            onCropImage?(id)
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 80, height: 80)
                                Image(systemName: "crop")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        
                        // Delete Button
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            onDeleteImage?(id)
                            pendingDeleteImageId = nil
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 80, height: 80)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func canvasContent(canvasSize: CGSize, gridHeight: CGFloat, cellWidth: CGFloat, cellHeight: CGFloat, effectiveScale: CGFloat) -> some View {
        ZStack {
            // Background with canvas zoom gesture
            Rectangle()
                .fill(backgroundColor)
                .frame(width: canvasSize.width, height: gridHeight)
                .onTapGesture {
                    pendingDeleteImageId = nil
                }
                .simultaneousGesture(
                    MagnificationGesture()
                        .updating($gesturePinchScale) { value, state, _ in
                            state = value
                        }
                        .onChanged { _ in
                            pendingDeleteImageId = nil
                        }
                        .onEnded { value in
                            canvasScale *= value
                            canvasScale = max(0.3, min(4.0, canvasScale))
                        }
                )
            
            // Images layer - sorted by z-order (last = top)
            ForEach(images) { canvasImage in
                SingleImageView(
                    canvasImage: canvasImage,
                    canvasSize: CGSize(width: canvasSize.width, height: gridHeight),
                    onManipulate: {
                        pendingDeleteImageId = nil
                        onImageManipulationStart?()
                        onBringToFront(canvasImage.id)
                    },
                    onUpdatePosition: { newPosition in
                        if let index = images.firstIndex(where: { $0.id == canvasImage.id }) {
                            images[index].position = newPosition
                        }
                    },
                    onUpdateScale: { newScale in
                        if let index = images.firstIndex(where: { $0.id == canvasImage.id }) {
                            images[index].scale = newScale
                        }
                    },
                    onUpdateRotation: { newRotation in
                        if let index = images.firstIndex(where: { $0.id == canvasImage.id }) {
                            images[index].rotation = newRotation
                        }
                    },
                    onLongPress: {
                        pendingDeleteImageId = canvasImage.id
                    }
                )
                .id(canvasImage.id) // Force proper view identity
            }
            
            // Grid overlay
            GridOverlayView(
                rows: gridRows,
                columns: gridColumns,
                cellWidth: cellWidth,
                cellHeight: cellHeight
            )
            .frame(width: canvasSize.width, height: gridHeight)
            .allowsHitTesting(false)
        }
        .frame(width: canvasSize.width, height: gridHeight)
        .scaleEffect(effectiveScale, anchor: .center)
        .frame(width: canvasSize.width * effectiveScale, height: gridHeight * effectiveScale)
        .onChange(of: images.count) { _, _ in
            pendingDeleteImageId = nil
        }
        .onChange(of: gridRows) { _, _ in
            pendingDeleteImageId = nil
        }
        .onChange(of: gridColumns) { _, _ in
            pendingDeleteImageId = nil
        }
        .onChange(of: backgroundColor) { _, _ in
            pendingDeleteImageId = nil
        }
    }
}

struct SingleImageView: View {
    let canvasImage: CanvasImage
    let canvasSize: CGSize
    var onManipulate: () -> Void
    var onUpdatePosition: ((CGPoint) -> Void)? = nil
    var onUpdateScale: ((CGFloat) -> Void)? = nil
    var onUpdateRotation: ((Angle) -> Void)? = nil
    var onLongPress: (() -> Void)? = nil
    
    // Canvas gesture states
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureRotation: Angle = .zero
    @State private var hasBeenBroughtToFront = false
    
    var body: some View {
        let imageSize = calculateImageSize()
        let effectiveScale = canvasImage.scale * gestureScale
        let effectiveRotation = canvasImage.rotation + gestureRotation
        let effectiveX = canvasImage.position.x + dragOffset.width
        let effectiveY = canvasImage.position.y + dragOffset.height
        
        Image(uiImage: canvasImage.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: imageSize.width, height: imageSize.height)
            .contentShape(Rectangle())
            .scaleEffect(effectiveScale)
            .rotationEffect(effectiveRotation)
            .position(x: effectiveX, y: effectiveY)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onLongPress?()
                    }
            )
            .gesture(
                dragGesture
                    .simultaneously(with: transformGesture)
            )
    }
    
    private func calculateImageSize() -> CGSize {
        let originalSize = canvasImage.image.size
        let scale = canvasSize.width / originalSize.width
        return CGSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onChanged { value in
                if !hasBeenBroughtToFront {
                    onManipulate()
                    hasBeenBroughtToFront = true
                }
            }
            .onEnded { value in
                // Update position via callback
                let newPosition = CGPoint(
                    x: canvasImage.position.x + value.translation.width,
                    y: canvasImage.position.y + value.translation.height
                )
                onUpdatePosition?(newPosition)
                hasBeenBroughtToFront = false
            }
    }
    
    private var transformGesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture(minimumScaleDelta: 0)
                .updating($gestureScale) { value, state, _ in
                    state = value
                }
                .onChanged { _ in
                    if !hasBeenBroughtToFront {
                        onManipulate()
                        hasBeenBroughtToFront = true
                    }
                }
                .onEnded { value in
                    let newScale = canvasImage.scale * value
                    onUpdateScale?(max(0.1, min(5.0, newScale)))
                    hasBeenBroughtToFront = false
                },
            RotationGesture(minimumAngleDelta: .zero)
                .updating($gestureRotation) { value, state, _ in
                    state = value
                }
                .onChanged { _ in
                    if !hasBeenBroughtToFront {
                        onManipulate()
                        hasBeenBroughtToFront = true
                    }
                }
                .onEnded { value in
                    let newRotation = canvasImage.rotation + value
                    onUpdateRotation?(newRotation)
                    hasBeenBroughtToFront = false
                }
        )
    }
}

/// Grid overlay showing cell boundaries
struct GridOverlayView: View {
    let rows: Int
    let columns: Int
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let lineWidth: CGFloat = 2
            
            for row in 0..<rows {
                for col in 0..<columns {
                    let x = CGFloat(col) * cellWidth
                    let y = CGFloat(row) * cellHeight
                    let rect = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
                    
                    context.stroke(Path(rect), with: .color(.black.opacity(0.6)), lineWidth: lineWidth + 1)
                    context.stroke(Path(rect), with: .color(.white.opacity(0.8)), lineWidth: lineWidth)
                }
            }
        }
    }
}
