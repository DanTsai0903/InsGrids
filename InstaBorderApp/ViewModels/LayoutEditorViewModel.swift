import SwiftUI
import Photos

class LayoutEditorViewModel: ObservableObject {
    @Published var config: LayoutConfiguration
    @Published var photos: [LayoutPhoto]

    let template: LayoutTemplate

    // MARK: - Undo Stack
    private struct EditorState {
        let config: LayoutConfiguration
        let photoStates: [(image: UIImage?, scale: CGFloat, offset: CGSize, version: Int)]
    }

    private var undoStack: [EditorState] = []
    private let maxUndoLevels = 20

    @Published private(set) var canUndo: Bool = false

    /// Check if any adjustments have been made from defaults
    var hasAdjustments: Bool {
        // Check config changes from defaults
        let defaultConfig = LayoutConfiguration(template: template.id)
        if config.outerBorderWidth != defaultConfig.outerBorderWidth ||
           config.innerSpacing != defaultConfig.innerSpacing ||
           config.cornerRadius != defaultConfig.cornerRadius ||
           config.aspectRatio != defaultConfig.aspectRatio {
            return true
        }
        // Check photo transforms
        for photo in photos {
            if photo.scale != 1.0 || photo.offset != .zero {
                return true
            }
        }
        return false
    }

    init(template: LayoutTemplate, images: [UIImage]) {
        self.template = template
        self.config = LayoutConfiguration(template: template.id)
        // Initialize all slots, filling with provided images or empty slots
        self.photos = (0..<template.slots.count).map { index in
            if index < images.count {
                return LayoutPhoto(image: images[index])
            } else {
                return LayoutPhoto(image: nil)
            }
        }
    }

    /// Add or replace photo at a specific slot index
    func setPhoto(_ image: UIImage, at index: Int, resetTransform: Bool = true) {
        guard index < photos.count else { return }
        saveSnapshot()
        photos[index].image = image
        photos[index].version += 1  // Trigger view update
        if resetTransform {
            photos[index].scale = 1.0
            photos[index].offset = .zero
        }
    }

    /// Update photo image preserving current transform (for edit/crop)
    func updatePhotoImage(_ image: UIImage, at index: Int) {
        setPhoto(image, at: index, resetTransform: false)
    }

    /// Remove photo from a specific slot index
    func removePhoto(at index: Int) {
        guard index < photos.count else { return }
        saveSnapshot()
        photos[index].image = nil
        photos[index].scale = 1.0
        photos[index].offset = .zero
        photos[index].version += 1  // Trigger view update
    }

    // MARK: - Undo/Reset

    /// Save current state before making changes
    func saveSnapshot() {
        let state = EditorState(
            config: config,
            photoStates: photos.map { ($0.image, $0.scale, $0.offset, $0.version) }
        )
        undoStack.append(state)
        if undoStack.count > maxUndoLevels {
            undoStack.removeFirst()
        }
        canUndo = true
    }

    /// Undo to previous state
    func undo() {
        guard let lastState = undoStack.popLast() else { return }
        config = lastState.config
        for (index, photoState) in lastState.photoStates.enumerated() {
            guard index < photos.count else { continue }
            photos[index].image = photoState.image
            photos[index].scale = photoState.scale
            photos[index].offset = photoState.offset
            photos[index].version = photoState.version
        }
        canUndo = !undoStack.isEmpty
    }

    /// Reset all adjustments to defaults
    func reset() {
        // Save current state for undo before resetting
        saveSnapshot()

        // Reset config to defaults
        config = LayoutConfiguration(template: template.id)

        // Reset all photo transforms
        for i in photos.indices {
            photos[i].scale = 1.0
            photos[i].offset = .zero
        }
    }

    func updatePhoto(at index: Int, scale: CGFloat, offset: CGSize) {
        guard index < photos.count else { return }
        photos[index].scale = scale
        photos[index].offset = offset
    }
    
    func renderAndSave(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            guard let rendered = self.renderLayout() else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    DispatchQueue.main.async { completion(false) }
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: rendered)
                }) { success, error in
                    DispatchQueue.main.async {
                        completion(success)
                    }
                }
            }
        }
    }
    
    private func renderLayout() -> UIImage? {
        // Render at high resolution
        let scale: CGFloat = 3.0
        let canvasWidth: CGFloat = 1080 // Instagram standard width
        let canvasHeight = canvasWidth / config.aspectRatio
        let canvasSize = CGSize(width: canvasWidth, height: canvasHeight)
        
        let contentSize = CGSize(
            width: canvasSize.width - 2 * config.outerBorderWidth * scale,
            height: canvasSize.height - 2 * config.outerBorderWidth * scale
        )
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // We're handling scale ourselves
        
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        
        return renderer.image { context in
            // Draw background
            UIColor(config.backgroundColor).setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))
            
            // Save context state
            context.cgContext.saveGState()
            
            // Translate to content origin (accounting for outer border)
            context.cgContext.translateBy(x: config.outerBorderWidth * scale, y: config.outerBorderWidth * scale)
            
            // Draw each slot
            for (index, slot) in template.slots.enumerated() {
                guard index < photos.count else { continue }

                let photo = photos[index]
                // Skip empty slots
                guard let image = photo.image else { continue }

                let edgeInsets = template.edgeInsets(for: index, innerSpacing: config.innerSpacing * scale)
                let movableIndices = template.movablePointIndices(for: index)
                let shapePath = slot.path(
                    in: contentSize,
                    edgeInsets: edgeInsets,
                    cornerRadius: config.cornerRadius * scale,
                    sharedPointIndices: movableIndices
                )

                // Clip to shape
                context.cgContext.saveGState()
                context.cgContext.addPath(shapePath.cgPath)
                context.cgContext.clip()

                // Calculate image draw rect
                let boundingRect = shapePath.boundingRect
                let imageSize = image.size
                let aspectRatio = imageSize.width / imageSize.height

                var drawSize = boundingRect.size
                if aspectRatio > (boundingRect.width / boundingRect.height) {
                    drawSize.width = boundingRect.height * aspectRatio
                } else {
                    drawSize.height = boundingRect.width / aspectRatio
                }

                // Apply photo scale
                drawSize.width *= photo.scale
                drawSize.height *= photo.scale

                // Center image in bounding rect and apply offset
                var drawRect = CGRect(
                    x: boundingRect.midX - drawSize.width / 2,
                    y: boundingRect.midY - drawSize.height / 2,
                    width: drawSize.width,
                    height: drawSize.height
                )

                drawRect.origin.x += photo.offset.width * scale
                drawRect.origin.y += photo.offset.height * scale

                // Draw image
                image.draw(in: drawRect)

                context.cgContext.restoreGState()
            }
            
            context.cgContext.restoreGState()
        }
    }
}
