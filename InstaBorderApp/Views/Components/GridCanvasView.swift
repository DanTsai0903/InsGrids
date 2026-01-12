import SwiftUI

/// Represents an image placed on the freeform canvas
struct CanvasImage: Identifiable {
    var id = UUID()
    var image: UIImage
    
    // Transform properties
    var position: CGPoint = .zero  // Center position on canvas
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    
    // Photo adjustments (brightness, contrast, filters, etc.)
    var adjustments: PhotoAdjustments = PhotoAdjustments()
}

/// Codable version of CanvasImage for persistence (Metadata only)
struct SavedCanvasImage: Codable {
    let id: UUID
    let positionX: CGFloat
    let positionY: CGFloat
    let scale: CGFloat
    let rotationDegrees: Double
    let adjustments: PhotoAdjustments
    
    init(from canvasImage: CanvasImage) {
        self.id = canvasImage.id
        self.positionX = canvasImage.position.x
        self.positionY = canvasImage.position.y
        self.scale = canvasImage.scale
        self.rotationDegrees = canvasImage.rotation.degrees
        self.adjustments = canvasImage.adjustments
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
    var onEditImage: ((UUID) -> Void)? = nil  // Photo adjustments & filters
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
                
                // Centered action buttons overlay (Edit, Crop & Delete)
                if let id = pendingDeleteImageId {
                    HStack(spacing: 30) {
                        // Edit Button (Photo Adjustments & Filters)
                        Button {
                            pendingDeleteImageId = nil
                            onEditImage?(id)
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 70, height: 70)
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.purple)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        
                        // Crop Button
                        Button {
                            pendingDeleteImageId = nil
                            onCropImage?(id)
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 70, height: 70)
                                Image(systemName: "crop")
                                    .font(.system(size: 30, weight: .bold))
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
                                Circle().fill(Color.white).frame(width: 70, height: 70)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 30, weight: .bold))
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

/// Helper for snapping behavior
enum SnapHelper {
    /// Snaps rotation to cardinal angles (0, 90, 180, 270) if within threshold
    /// Returns the snapped angle and whether a snap occurred
    static func snapRotation(_ angle: Angle, threshold: Double = 2.0) -> (snapped: Angle, didSnap: Bool) {
        let cardinalAngles: [Double] = [0, 90, 180, 270, 360, -90, -180, -270]
        let degrees = angle.degrees
        
        for cardinal in cardinalAngles {
            if abs(degrees - cardinal) <= threshold {
                // Normalize to 0-360 range
                var snappedDegrees = cardinal.truncatingRemainder(dividingBy: 360)
                if snappedDegrees < 0 { snappedDegrees += 360 }
                return (Angle(degrees: snappedDegrees), true)
            }
        }
        return (angle, false)
    }
    
    /// Checks if rotation is at a cardinal angle (parallel to canvas)
    static func isParallel(_ angle: Angle, tolerance: Double = 1.0) -> Bool {
        let cardinalAngles: [Double] = [0, 90, 180, 270]
        let normalizedDegrees = angle.degrees.truncatingRemainder(dividingBy: 360)
        let degrees = normalizedDegrees < 0 ? normalizedDegrees + 360 : normalizedDegrees
        
        return cardinalAngles.contains { abs(degrees - $0) <= tolerance }
    }
    
    /// Snaps position to canvas edges if within threshold and image is parallel
    /// Returns the snapped position and whether a snap occurred
    static func snapPosition(
        _ position: CGPoint,
        imageSize: CGSize,
        scale: CGFloat,
        rotation: Angle,
        canvasSize: CGSize,
        threshold: CGFloat = 3.0
    ) -> (snapped: CGPoint, didSnap: Bool) {
        // Only snap when image is parallel to canvas
        guard isParallel(rotation) else {
            return (position, false)
        }
        
        let normalizedDegrees = rotation.degrees.truncatingRemainder(dividingBy: 360)
        let degrees = normalizedDegrees < 0 ? normalizedDegrees + 360 : normalizedDegrees
        let isRotated90or270 = abs(degrees - 90) < 1 || abs(degrees - 270) < 1
        
        // Calculate effective image dimensions after rotation
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        let effectiveWidth = isRotated90or270 ? scaledHeight : scaledWidth
        let effectiveHeight = isRotated90or270 ? scaledWidth : scaledHeight
        
        var newPosition = position
        var didSnap = false
        
        // Calculate image edges
        let leftEdge = position.x - effectiveWidth / 2
        let rightEdge = position.x + effectiveWidth / 2
        let topEdge = position.y - effectiveHeight / 2
        let bottomEdge = position.y + effectiveHeight / 2
        
        // Snap to left edge
        if abs(leftEdge) <= threshold {
            newPosition.x = effectiveWidth / 2
            didSnap = true
        }
        // Snap to right edge
        else if abs(rightEdge - canvasSize.width) <= threshold {
            newPosition.x = canvasSize.width - effectiveWidth / 2
            didSnap = true
        }
        
        // Snap to top edge
        if abs(topEdge) <= threshold {
            newPosition.y = effectiveHeight / 2
            didSnap = true
        }
        // Snap to bottom edge
        else if abs(bottomEdge - canvasSize.height) <= threshold {
            newPosition.y = canvasSize.height - effectiveHeight / 2
            didSnap = true
        }
        
        return (newPosition, didSnap)
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
    
    // Use @State for real-time snapping during gesture
    @State private var dragOffset: CGSize = .zero
    @State private var isCurrentlySnappedX = false
    @State private var isCurrentlySnappedY = false
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var gestureRotationRaw: Angle = .zero
    @State private var isCurrentlySnappedRotation = false
    @State private var hasBeenBroughtToFront = false
    
    var body: some View {
        let imageSize = calculateImageSize()
        let effectiveScale = canvasImage.scale * gestureScale
        
        // Apply real-time rotation snapping
        let rawRotation = canvasImage.rotation + gestureRotationRaw
        let (snappedRotation, _) = SnapHelper.snapRotation(rawRotation)
        let effectiveRotation = snappedRotation
        
        // Apply real-time position snapping
        let rawPosition = CGPoint(
            x: canvasImage.position.x + dragOffset.width,
            y: canvasImage.position.y + dragOffset.height
        )
        let (snappedPosition, _) = SnapHelper.snapPosition(
            rawPosition,
            imageSize: imageSize,
            scale: canvasImage.scale,
            rotation: effectiveRotation,
            canvasSize: canvasSize
        )
        
        Image(uiImage: canvasImage.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: imageSize.width, height: imageSize.height)
            .contentShape(Rectangle())
            .scaleEffect(effectiveScale)
            .rotationEffect(effectiveRotation)
            .position(x: snappedPosition.x, y: snappedPosition.y)
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
            .onChanged { value in
                if !hasBeenBroughtToFront {
                    onManipulate()
                    hasBeenBroughtToFront = true
                }
                
                dragOffset = value.translation
                
                // Check for snap and provide haptic feedback
                let rawPosition = CGPoint(
                    x: canvasImage.position.x + value.translation.width,
                    y: canvasImage.position.y + value.translation.height
                )
                let imageSize = calculateImageSize()
                let currentRotation = canvasImage.rotation + gestureRotationRaw
                let (snappedRotation, _) = SnapHelper.snapRotation(currentRotation)
                
                let (snappedPosition, _) = SnapHelper.snapPosition(
                    rawPosition,
                    imageSize: imageSize,
                    scale: canvasImage.scale,
                    rotation: snappedRotation,
                    canvasSize: canvasSize
                )
                
                // Check X-axis snap
                let didSnapX = abs(snappedPosition.x - rawPosition.x) > 0.1
                if didSnapX && !isCurrentlySnappedX {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    isCurrentlySnappedX = true
                } else if !didSnapX {
                    isCurrentlySnappedX = false
                }
                
                // Check Y-axis snap
                let didSnapY = abs(snappedPosition.y - rawPosition.y) > 0.1
                if didSnapY && !isCurrentlySnappedY {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    isCurrentlySnappedY = true
                } else if !didSnapY {
                    isCurrentlySnappedY = false
                }
            }
            .onEnded { value in
                // Calculate final snapped position
                let rawPosition = CGPoint(
                    x: canvasImage.position.x + value.translation.width,
                    y: canvasImage.position.y + value.translation.height
                )
                let imageSize = calculateImageSize()
                let currentRotation = canvasImage.rotation + gestureRotationRaw
                let (snappedRotation, _) = SnapHelper.snapRotation(currentRotation)
                
                let (snappedPosition, _) = SnapHelper.snapPosition(
                    rawPosition,
                    imageSize: imageSize,
                    scale: canvasImage.scale,
                    rotation: snappedRotation,
                    canvasSize: canvasSize
                )
                
                onUpdatePosition?(snappedPosition)
                dragOffset = .zero
                isCurrentlySnappedX = false
                isCurrentlySnappedY = false
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
                .onChanged { value in
                    if !hasBeenBroughtToFront {
                        onManipulate()
                        hasBeenBroughtToFront = true
                    }
                    
                    gestureRotationRaw = value
                    
                    // Check for snap and provide haptic feedback
                    let rawRotation = canvasImage.rotation + value
                    let (_, didSnap) = SnapHelper.snapRotation(rawRotation)
                    
                    if didSnap && !isCurrentlySnappedRotation {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        isCurrentlySnappedRotation = true
                    } else if !didSnap {
                        isCurrentlySnappedRotation = false
                    }
                }
                .onEnded { value in
                    let rawRotation = canvasImage.rotation + value
                    let (snappedRotation, _) = SnapHelper.snapRotation(rawRotation)
                    
                    onUpdateRotation?(snappedRotation)
                    gestureRotationRaw = .zero
                    isCurrentlySnappedRotation = false
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
