import SwiftUI
import PhotosUI
import Combine

/// ViewModel for managing freeform grid canvas state
///
/// ## Memory Management Guarantees
/// - **Proxy Workflow**: User edits with 1200px downsampled proxies, originals cached to disk
/// - **Cache Cleanup**: Orphaned files removed every 5 seconds during auto-save
/// - **Lifecycle Hooks**: Cache cleanup triggered when app backgrounds/terminates
/// - **Size Limits**: 500MB soft limit enforced with oldest-first deletion
/// - **Integrity Checks**: Corrupted/orphaned files validated and removed on launch
/// - **Autoreleasepool**: Tile export uses autoreleasepool to prevent OOM on large grids
/// - **Singleton Reuse**: PhotoEditorEngine.shared reused across all renders to minimize GPU overhead
@MainActor
class GridViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var rows: Int = 2
    @Published var columns: Int = 3  // Default 2×3
    @Published var backgroundColor: Color = .white
    @Published var canvasImages: [CanvasImage] = []
    @Published var textElements: [TextElement] = []
    @Published var stickerElements: [StickerElement] = []
    @Published var selectedElementId: UUID? = nil
    @Published var isProcessing = false
    @Published var showRestoreAlert = false
    @Published var autoSaveStatus: String = ""

    // Z-index counter for bringing elements to front
    private var nextZIndex: Int = 1
    
    // MARK: - Undo Stack
    
    private var undoStack: [CanvasState] = []
    private let maxUndoLevels = 20
    
    var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    // MARK: - Private Properties
    
    private var autoSaveTimer: Timer?
    private let autoSaveKey = "com.insgrids.autosave.grid"
    
    private var autosaveFolder: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let folder = paths[0].appendingPathComponent("autosave_images")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }
    
    private var originalsFolder: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let folder = paths[0].appendingPathComponent("original_images")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }
    
    // MARK: - Initialization

    init() {
        validateCacheIntegrity()
        checkForAutoSave()
        enforceStorageLimit()
    }
    
    deinit {
        // GridViewModel is @MainActor, deinit is nonisolated.
        // We can't call stopAutoSave() here. 
        // [weak self] in the timer ensures we don't leak.
    }
    
    // MARK: - Grid Configuration
    
    /// Update grid dimensions
    func updateGridSize(rows: Int, columns: Int) {
        saveSnapshot()
        self.rows = min(max(1, rows), 6)
        self.columns = min(max(1, columns), 6)
    }
    
    /// Set background color
    func setBackgroundColor(_ color: Color) {
        saveSnapshot()
        backgroundColor = color
    }
    
    // MARK: - Image Management
    
    /// Add images to canvas (centered)
    /// Add images to canvas (centered) - Proxy Workflow
    func addImages(_ newImagesData: [Data], canvasSize: CGSize) {
        saveSnapshot()
        for data in newImagesData {
            // 1. Downsample for Display (Proxy)
            guard let displayImage = downsample(data: data, maxDimension: 1200) else { continue }
            
            // Use center position, or fallback to reasonable default if canvasSize is zero
            let centerX = canvasSize.width > 0 ? canvasSize.width / 2 : 200
            let centerY = canvasSize.height > 0 ? canvasSize.height / 2 : 250
            
            let canvasImage = CanvasImage(
                image: displayImage,
                position: CGPoint(x: centerX, y: centerY)
            )
            
            // 2. Save Original to Disk
            saveOriginal(data: data, id: canvasImage.id)
            
            canvasImages.append(canvasImage)
        }
        
        // Force SwiftUI to recognize the view state change
        // This helps stabilize the view before any crop operations
        objectWillChange.send()
    }
    
    /// Remove image by ID
    func removeImage(_ id: UUID) {
        saveSnapshot()
        canvasImages.removeAll { $0.id == id }
        // Clean up original
        let fileURL = originalsFolder.appendingPathComponent("\(id.uuidString).jpg")
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    /// Update image content (e.g. after cropping)
    /// Update image content (e.g. after cropping)
    func updateImage(_ id: UUID, newImage: UIImage) {
        saveSnapshot()
        if let index = canvasImages.firstIndex(where: { $0.id == id }) {
            // 1. Save High-Res Original
            if let data = newImage.jpegData(compressionQuality: 1.0) {
                saveOriginal(data: data, id: id)

                // 2. Update Model with Downsampled Proxy
                if let proxy = downsample(data: data, maxDimension: 1200) {
                    canvasImages[index].image = proxy
                } else {
                    // Fallback if downsample fails (unlikely)
                    canvasImages[index].image = newImage
                }
            }
        }
    }
    
    /// Update photo adjustments (brightness, contrast, filters, etc.)
    func updateAdjustments(_ id: UUID, adjustments: PhotoAdjustments) {
        saveSnapshot()
        if let index = canvasImages.firstIndex(where: { $0.id == id }) {
            canvasImages[index].adjustments = adjustments
        }
    }
    
    /// Move image to front (top layer) by ID
    func bringToFront(_ id: UUID) {
        guard let index = canvasImages.firstIndex(where: { $0.id == id }) else { return }
        canvasImages[index].zIndex = nextZIndex
        nextZIndex += 1
    }

    /// Move text element to front (top layer) by ID
    func bringTextToFront(_ id: UUID) {
        guard let index = textElements.firstIndex(where: { $0.id == id }) else { return }
        textElements[index].zIndex = nextZIndex
        nextZIndex += 1
    }

    /// Move sticker element to front (top layer) by ID
    func bringStickerToFront(_ id: UUID) {
        guard let index = stickerElements.firstIndex(where: { $0.id == id }) else { return }
        stickerElements[index].zIndex = nextZIndex
        nextZIndex += 1
    }
    
    /// Save current image states for undo (call before changes)
    func saveImageSnapshot() {
        saveSnapshot()
    }
    
    // MARK: - Text Element Management
    
    /// Add text element to canvas
    func addTextElement(_ element: TextElement) {
        saveSnapshot()
        textElements.append(element)
    }
    
    /// Update existing text element
    func updateTextElement(_ id: UUID, with element: TextElement) {
        saveSnapshot()
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index] = element
        }
    }
    
    /// Remove text element by ID
    func removeTextElement(_ id: UUID) {
        saveSnapshot()
        textElements.removeAll { $0.id == id }
    }
    
    /// Update text element position
    func updateTextPosition(_ id: UUID, position: CGPoint) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].position = position
        }
    }
    
    /// Update text element scale
    func updateTextScale(_ id: UUID, scale: CGFloat) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].scale = scale
        }
    }
    
    /// Update text element rotation
    func updateTextRotation(_ id: UUID, rotation: Angle) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].rotation = rotation
        }
    }
    
    // MARK: - Sticker Element Management
    
    /// Add sticker element to canvas
    func addStickerElement(_ element: StickerElement) {
        saveSnapshot()
        stickerElements.append(element)
    }
    
    /// Remove sticker element by ID
    func removeStickerElement(_ id: UUID) {
        saveSnapshot()
        stickerElements.removeAll { $0.id == id }
    }
    
    /// Update sticker element position
    func updateStickerPosition(_ id: UUID, position: CGPoint) {
        if let index = stickerElements.firstIndex(where: { $0.id == id }) {
            stickerElements[index].position = position
        }
    }
    
    /// Update sticker element scale
    func updateStickerScale(_ id: UUID, scale: CGFloat) {
        if let index = stickerElements.firstIndex(where: { $0.id == id }) {
            stickerElements[index].scale = scale
        }
    }
    
    /// Update sticker element rotation
    func updateStickerRotation(_ id: UUID, rotation: Angle) {
        if let index = stickerElements.firstIndex(where: { $0.id == id }) {
            stickerElements[index].rotation = rotation
        }
    }
    
    // MARK: - Selection
    
    /// Select an element
    func selectElement(_ id: UUID) {
        selectedElementId = id
    }
    
    /// Deselect current element
    func deselectElement() {
        selectedElementId = nil
    }
    
    // MARK: - Undo
    
    private func saveSnapshot() {
        // Lightweight snapshot: copy image array with value-type transforms
        let imagesCopy = canvasImages.map { image -> CanvasImage in
            var copy = CanvasImage(image: image.image)
            copy.id = image.id
            copy.position = image.position
            copy.scale = image.scale
            copy.rotation = image.rotation
            copy.zIndex = image.zIndex
            return copy
        }
        let state = CanvasState(
            images: imagesCopy,
            rows: rows,
            columns: columns,
            backgroundColor: backgroundColor
        )
        undoStack.append(state)
        if undoStack.count > maxUndoLevels {
            undoStack.removeFirst()
        }
    }
    
    func undo() {
        guard let lastState = undoStack.popLast() else { return }
        rows = lastState.rows
        columns = lastState.columns
        canvasImages = lastState.images
        backgroundColor = lastState.backgroundColor
    }
    
    // MARK: - Auto-Save
    
    // MARK: - Auto-Save
    
    func startAutoSave() {
        stopAutoSave()
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.saveState()
            }
        }
    }
    
    func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    /// Clean up orphaned files from both cache folders
    /// - Parameter activeIds: Set of UUIDs for currently active images
    nonisolated private func cleanupOrphanedFiles(activeIds: Set<UUID>) {
        // Build folder URLs directly (nonisolated, no access to self)
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let autosaveURL = cachesDir.appendingPathComponent("autosave_images")
        let originalsURL = cachesDir.appendingPathComponent("original_images")

        Task.detached(priority: .background) {
            // Clean both autosave and original image folders
            for folder in [autosaveURL, originalsURL] {
                if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                    for file in files {
                        let filename = file.deletingPathExtension().lastPathComponent
                        // Try to parse UUID, remove file if not in active set
                        if let uuid = UUID(uuidString: filename), !activeIds.contains(uuid) {
                            try? FileManager.default.removeItem(at: file)
                        } else if UUID(uuidString: filename) == nil {
                            // Invalid UUID filename, remove orphaned file
                            try? FileManager.default.removeItem(at: file)
                        }
                    }
                }
            }
        }
    }

    private func saveState() {
        // Capture everything we need from MainActor
        let imagesToSave = canvasImages.map { (id: $0.id, image: $0.image) }
        let currentMetadata = configMetadata()
        let folder = autosaveFolder
        let key = autoSaveKey

        // Push heavy work to background
        Task.detached(priority: .background) {
            // 1. Cleanup orphaned files from both folders
            let activeIds = Set(imagesToSave.map { $0.id })
            self.cleanupOrphanedFiles(activeIds: activeIds)

            // 2. Save Images
            for item in imagesToSave {
                let fileURL = folder.appendingPathComponent("\(item.id).jpg")
                if let data = item.image.jpegData(compressionQuality: 0.8) {
                    try? data.write(to: fileURL)
                }
            }

            // 3. Save Metadata
            if let data = try? JSONEncoder().encode(currentMetadata) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
    
    private func configMetadata() -> GridAutoSaveConfig {
        let savedImages = canvasImages.map { SavedCanvasImage(from: $0) }
        return GridAutoSaveConfig(
            rows: rows,
            columns: columns,
            images: savedImages,
            backgroundColorHex: backgroundColor.toHex()
        )
    }
    
    private func checkForAutoSave() {
        guard let data = UserDefaults.standard.data(forKey: autoSaveKey),
              let config = try? JSONDecoder().decode(GridAutoSaveConfig.self, from: data),
              !config.images.isEmpty else { return }
        showRestoreAlert = true
    }
    
    func restoreSession() {
        if let data = UserDefaults.standard.data(forKey: autoSaveKey),
           let config = try? JSONDecoder().decode(GridAutoSaveConfig.self, from: data) {
            rows = config.rows
            columns = config.columns
            
            // Map metadata back to CanvasImages, loading actual data from disk
            canvasImages = config.images.compactMap { saved in
                let fileURL = autosaveFolder.appendingPathComponent("\(saved.id).jpg")
                guard let data = try? Data(contentsOf: fileURL),
                      let uiImage = UIImage(data: data) else { return nil }

                var canvasImage = CanvasImage(image: uiImage)
                canvasImage.id = saved.id
                canvasImage.position = CGPoint(x: saved.positionX, y: saved.positionY)
                canvasImage.scale = saved.scale
                canvasImage.rotation = Angle(degrees: saved.rotationDegrees)
                canvasImage.zIndex = saved.zIndex
                return canvasImage
            }
            
            if let color = Color(hex: config.backgroundColorHex) {
                backgroundColor = color
            }
        }
        showRestoreAlert = false
    }
    
    func discardSession() {
        clearAutoSave()
        showRestoreAlert = false
    }
    
    func clearAutoSave() {
        UserDefaults.standard.removeObject(forKey: autoSaveKey)

        // Clean up all cache files (pass empty set to remove everything)
        cleanupOrphanedFiles(activeIds: Set())
    }

    /// Perform lifecycle cleanup when app backgrounds/terminates
    /// Removes orphaned files while keeping active ones
    func performLifecycleCleanup() {
        let activeIds = Set(canvasImages.map { $0.id })
        cleanupOrphanedFiles(activeIds: activeIds)
    }

    // MARK: - Cache Size Management

    /// Calculate total cache size in bytes
    private func totalCacheSize() -> Int {
        var total = 0
        let folders = [autosaveFolder, originalsFolder]

        for folder in folders {
            if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.fileSizeKey]) {
                for file in files {
                    if let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
                       let size = attrs[.size] as? Int {
                        total += size
                    }
                }
            }
        }
        return total
    }

    /// Delete oldest cache files until total size is under limit
    /// - Parameter limit: Maximum cache size in bytes
    private func deleteOldestFiles(until limit: Int) {
        let folders = [autosaveFolder, originalsFolder]
        var allFiles: [(url: URL, date: Date, size: Int)] = []

        // Collect all files with metadata
        for folder in folders {
            if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey]) {
                for file in files {
                    if let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
                       let date = attrs[.creationDate] as? Date,
                       let size = attrs[.size] as? Int {
                        allFiles.append((url: file, date: date, size: size))
                    }
                }
            }
        }

        // Sort by creation date (oldest first)
        allFiles.sort { $0.date < $1.date }

        // Delete oldest files until under limit
        var currentSize = allFiles.reduce(0) { $0 + $1.size }
        for file in allFiles {
            if currentSize <= limit {
                break
            }
            try? FileManager.default.removeItem(at: file.url)
            currentSize -= file.size
        }
    }

    /// Enforce cache size limit (500MB soft limit)
    func enforceStorageLimit() {
        let limit = 500 * 1024 * 1024 // 500MB
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            let size = await MainActor.run { self.totalCacheSize() }
            if size > limit {
                await MainActor.run { self.deleteOldestFiles(until: limit) }
            }
        }
    }

    /// Validate cache integrity and remove corrupted/orphaned files
    /// Runs on app launch to ensure clean state
    func validateCacheIntegrity() {
        let autosave = autosaveFolder
        let originals = originalsFolder
        let key = autoSaveKey

        Task.detached(priority: .background) {
            // Get active IDs from UserDefaults metadata
            var activeIds = Set<UUID>()
            if let data = UserDefaults.standard.data(forKey: key),
               let config = try? JSONDecoder().decode(GridAutoSaveConfig.self, from: data) {
                activeIds = Set(config.images.map { $0.id })
            }

            // Check autosave folder for orphaned files
            if let files = try? FileManager.default.contentsOfDirectory(at: autosave, includingPropertiesForKeys: nil) {
                for file in files {
                    let filename = file.deletingPathExtension().lastPathComponent
                    if let uuid = UUID(uuidString: filename) {
                        // Valid UUID, but not in metadata - orphaned
                        if !activeIds.contains(uuid) {
                            try? FileManager.default.removeItem(at: file)
                        }
                    } else {
                        // Invalid UUID filename - remove
                        try? FileManager.default.removeItem(at: file)
                    }
                }
            }

            // Check both folders for corrupted image files
            for folder in [autosave, originals] {
                if let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                    for file in files where file.pathExtension == "jpg" {
                        // Try to load as image - if fails, it's corrupted
                        if UIImage(contentsOfFile: file.path) == nil {
                            try? FileManager.default.removeItem(at: file)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Export
    
    /// Generate tiles from current canvas state
    func generateTiles(canvasSize: CGSize) -> [UIImage] {
        let cellWidth = canvasSize.width / CGFloat(columns)
        let cellHeight = cellWidth / (4.0 / 5.0)
        let gridHeight = cellHeight * CGFloat(rows)
        
        // First render the entire canvas to an image
        guard let compositeImage = renderCanvas(size: CGSize(width: canvasSize.width, height: gridHeight)) else {
            return []
        }
        
        // Then slice into tiles
        var tiles: [UIImage] = []
        for row in 0..<rows {
            for col in 0..<columns {
                autoreleasepool {
                    let tileRect = CGRect(
                        x: CGFloat(col) * cellWidth,
                        y: CGFloat(row) * cellHeight,
                        width: cellWidth,
                        height: cellHeight
                    )
                    if let tile = cropImage(compositeImage, to: tileRect) {
                        tiles.append(tile)
                    }
                }
            }
        }
        return tiles
    }
    
    /// Get a snapshot of the current canvas for tools like eyedropper
    /// This includes content that extends beyond the canvas bounds
    func getCanvasSnapshot(size: CGSize) -> UIImage? {
        // Calculate bounding box of all content to include overflow
        let bounds = calculateContentBounds(canvasSize: size)
        
        // Render at the expanded size
        return renderCanvasWithOffset(canvasSize: size, contentBounds: bounds)
    }
    
    /// Calculate the bounding box that contains all visible content
    private func calculateContentBounds(canvasSize: CGSize) -> CGRect {
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        var maxX: CGFloat = canvasSize.width
        var maxY: CGFloat = canvasSize.height
        
        for canvasImage in canvasImages {
            // Calculate image size after fitting to canvas width
            let originalSize = canvasImage.image.size
            let fitScale = canvasSize.width / originalSize.width
            let drawWidth = originalSize.width * fitScale * canvasImage.scale
            let drawHeight = originalSize.height * fitScale * canvasImage.scale
            
            // Calculate rotated bounding box (approximate with max dimension)
            let diagonal = sqrt(drawWidth * drawWidth + drawHeight * drawHeight)
            let halfDiag = diagonal / 2
            
            // Calculate corners after transform
            let left = canvasImage.position.x - halfDiag
            let right = canvasImage.position.x + halfDiag
            let top = canvasImage.position.y - halfDiag
            let bottom = canvasImage.position.y + halfDiag
            
            minX = min(minX, left)
            minY = min(minY, top)
            maxX = max(maxX, right)
            maxY = max(maxY, bottom)
        }
        
        // Add some padding
        let padding: CGFloat = 20
        return CGRect(
            x: minX - padding,
            y: minY - padding,
            width: maxX - minX + padding * 2,
            height: maxY - minY + padding * 2
        )
    }
    
    /// Render canvas with offset to include content outside normal bounds
    private func renderCanvasWithOffset(canvasSize: CGSize, contentBounds: CGRect) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0  // Retina quality
        let renderer = UIGraphicsImageRenderer(size: contentBounds.size, format: format)
        
        // Calculate offset to translate content into view
        let offsetX = -contentBounds.origin.x
        let offsetY = -contentBounds.origin.y
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // Translate to account for content outside normal bounds
            cgContext.translateBy(x: offsetX, y: offsetY)
            
            // Background (draw at original canvas position)
            UIColor(backgroundColor).setFill()
            cgContext.fill(CGRect(origin: .zero, size: canvasSize))
            
            // Draw each image
            for canvasImage in canvasImages {
                cgContext.saveGState()
                
                // Move to image position
                cgContext.translateBy(x: canvasImage.position.x, y: canvasImage.position.y)
                
                // Apply rotation
                cgContext.rotate(by: canvasImage.rotation.radians)
                
                // Apply scale
                cgContext.scaleBy(x: canvasImage.scale, y: canvasImage.scale)
                
                // Calculate image size (fit to canvas width initially)
                let originalSize = canvasImage.image.size
                let fitScale = canvasSize.width / originalSize.width
                let drawWidth = originalSize.width * fitScale
                let drawHeight = originalSize.height * fitScale
                
                // Draw image centered at origin (we already translated)
                let rect = CGRect(x: -drawWidth/2, y: -drawHeight/2, width: drawWidth, height: drawHeight)
                canvasImage.image.draw(in: rect)
                
                cgContext.restoreGState()
            }
        }
    }
    
    private func renderCanvas(size: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0  // Retina quality
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            // Background
            UIColor(backgroundColor).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw each image
            for canvasImage in canvasImages {
                let cgContext = context.cgContext
                cgContext.saveGState()
                
                // Move to image position
                cgContext.translateBy(x: canvasImage.position.x, y: canvasImage.position.y)
                
                // Apply rotation
                cgContext.rotate(by: canvasImage.rotation.radians)
                
                // Apply scale
                cgContext.scaleBy(x: canvasImage.scale, y: canvasImage.scale)
                
                // Calculate image size (fit to canvas width initially)
                let originalSize = canvasImage.image.size
                let fitScale = size.width / originalSize.width
                let drawWidth = originalSize.width * fitScale
                let drawHeight = originalSize.height * fitScale
                
                // Draw image centered at origin (we already translated)
                let rect = CGRect(x: -drawWidth/2, y: -drawHeight/2, width: drawWidth, height: drawHeight)
                canvasImage.image.draw(in: rect)
                
                cgContext.restoreGState()
            }
        }
    }
    
    private func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        let scale = image.scale
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
        
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
    }
    
    /// Export all tiles (High Resolution)
    func exportTiles(canvasSize: CGSize, completion: @escaping (Bool, Int) -> Void) {
        isProcessing = true
        
        // 1. Capture State on Main Actor
        let imagesSnapshot = self.canvasImages
        let rows = self.rows
        let cols = self.columns
        let bg = self.backgroundColor
        let folder = self.originalsFolder
        
        // 2. Offload to Background
        Task.detached(priority: .userInitiated) {
            let tiles = self.generateHighResTiles(
                images: imagesSnapshot,
                rows: rows,
                cols: cols,
                bg: bg,
                canvasSize: canvasSize,
                originalsFolder: folder
            )
            
            // 3. Save Tiles
            var successCount = 0
            let tileCount = tiles.count
            
            for tile in tiles {
                autoreleasepool {
                    let semaphore = DispatchSemaphore(value: 0)
                    var saveSuccess = false
                    
                    ImageExporter.shared.saveImage(tile) { success, _ in
                        saveSuccess = success
                        semaphore.signal()
                    }
                    
                    _ = semaphore.wait(timeout: .now() + 30)
                    if saveSuccess {
                        successCount += 1
                    }
                }
            }
            
            // 4. Finish on Main Actor
            let finalCount = successCount
            await MainActor.run { [weak self] in
                self?.isProcessing = false
                completion(finalCount == tileCount, finalCount)
                // Enforce cache size limit after export
                self?.enforceStorageLimit()
            }
        }
    }
    
    // MARK: - Render Logic (Background Safe)
    
    nonisolated private func generateHighResTiles(images: [CanvasImage], rows: Int, cols: Int, bg: Color, canvasSize: CGSize, originalsFolder: URL) -> [UIImage] {
        let cellWidth = canvasSize.width / CGFloat(cols)
        let cellHeight = cellWidth / (4.0 / 5.0)
        
        var tiles: [UIImage] = []
        
        for row in 0..<rows {
            for col in 0..<cols {
                autoreleasepool {
                    let tileRect = CGRect(
                        x: CGFloat(col) * cellWidth,
                        y: CGFloat(row) * cellHeight,
                        width: cellWidth,
                        height: cellHeight
                    )
                    
                    if let tile = renderTile(
                        rect: tileRect,
                        canvasSize: canvasSize,
                        images: images,
                        bg: bg,
                        originalsFolder: originalsFolder
                    ) {
                        tiles.append(tile)
                    }
                }
            }
        }
        return tiles
    }
    
    nonisolated private func renderTile(rect: CGRect, canvasSize: CGSize, images: [CanvasImage], bg: Color, originalsFolder: URL) -> UIImage? {
        // Target Resolution: ~12MP (e.g. 3000x4000)
        let targetPixels: CGFloat = 12_000_000
        let tileArea = rect.width * rect.height
        // Scale factor to boost current point size to target pixels
        // scale^2 * area = targetPixels  => scale = sqrt(target / area)
        let scale = sqrt(targetPixels / tileArea)
        // Cap scale to prevent massive upscaling of empty space, but allow high res
        // Minimum scale 1.0
        let finalScale = max(1.0, scale)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = finalScale
        
        // Debug: Print output size
        // let w = rect.width * finalScale
        // let h = rect.height * finalScale
        // print("Rendering Tile at: \(w) x \(h)")
        
        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
        
        return renderer.image { context in
            // 1. Setup Context (Translate so tile origin is 0,0)
            let cgContext = context.cgContext
            cgContext.translateBy(x: -rect.origin.x, y: -rect.origin.y)
            
            // 2. Fill Background
            let uiColor = UIColor(bg) // Color is Sendable (SwiftUI), UIColor init is thread safe? Yes.
            uiColor.setFill()
            cgContext.fill(CGRect(origin: .zero, size: canvasSize)) // Fill total canvas area
            
            // 3. Draw Images
            for item in images {
                cgContext.saveGState()
                
                // Position
                cgContext.translateBy(x: item.position.x, y: item.position.y)
                cgContext.rotate(by: item.rotation.radians)
                cgContext.scaleBy(x: item.scale, y: item.scale)
                
                let proxySize = item.image.size // Low res size
                // We need to calculate drawing rect based on proxy size aspect?
                // Logic in renderCanvas:
                // let originalSize = canvasImage.image.size (Here it's proxy size)
                // let fitScale = canvasSize.width / originalSize.width
                // let drawWidth = originalSize.width * fitScale
                // let drawHeight = originalSize.height * fitScale
                
                // IMPORTANT: The geometric layout (position, scale) was based on PROXY image size (1200px)
                // or previously Full Res.
                // If we load High Res, it might have different pixel dimensions.
                // BUT aspectRatio should be same.
                // The drawing logic: 'fitScale' relies on 'canvasSize.width / originalSize.width'.
                // If we swap image, we must ensure we draw into the SAME rect.
                
                let originalSize = proxySize // Use layout from struct
                let fitScale = canvasSize.width / originalSize.width
                let drawWidth = originalSize.width * fitScale
                let drawHeight = originalSize.height * fitScale
                let imageRect = CGRect(x: -drawWidth/2, y: -drawHeight/2, width: drawWidth, height: drawHeight)

                // Check intersection with tile (optimization)
                // Transform is complex, simple bounds check might be hard.
                // But UIGraphics clips automatically. We rely on that for simplicity.
                
                // 4. Load High Res Asset
                let fileURL = originalsFolder.appendingPathComponent("\(item.id.uuidString).jpg")
                var drawImage: UIImage? = nil
                
                if let data = try? Data(contentsOf: fileURL) {
                    // Downsample to Target Size (Tile logical size * scale)
                    // Actually, we need it roughly the size of 'drawWidth' on screen * 'finalScale'
                    // Estimate pixel size needed:
                    let maxRenderPixelSize = max(drawWidth, drawHeight) * finalScale
                    
                    // Use helper to load efficiently
                    if let highRes = downsample(data: data, maxDimension: maxRenderPixelSize) {
                        drawImage = highRes
                    } else {
                        drawImage = UIImage(data: data) // Fallback
                    }
                }
                
                // Fallback to proxy if original missing
                if drawImage == nil {
                    drawImage = item.image
                }
                
                // Apply photo adjustments (brightness, contrast, filters, etc.)
                if let img = drawImage, item.adjustments.hasAdjustments {
                    drawImage = PhotoEditorEngine.shared.render(image: img, adjustments: item.adjustments)
                }
                
                if let finalImage = drawImage {
                    finalImage.draw(in: imageRect)
                }
                
                cgContext.restoreGState()
            }
        }
    }
    
    /// Reset to fresh state
    func clearAll() {
        canvasImages.removeAll()
        rows = 2
        columns = 2
        backgroundColor = .white
        clearAutoSave() // Also clears originals
    }
    
    // MARK: - Proxy Helpers
    
    private func saveOriginal(data: Data, id: UUID) {
        let fileURL = originalsFolder.appendingPathComponent("\(id.uuidString).jpg")
        try? data.write(to: fileURL)
    }
    
    func loadOriginal(id: UUID) -> UIImage? {
        let fileURL = originalsFolder.appendingPathComponent("\(id.uuidString).jpg")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    nonisolated private func downsample(data: Data, maxDimension: CGFloat) -> UIImage? {
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ] as CFDictionary
        
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Auto-Save Config

struct GridAutoSaveConfig: Codable {
    let rows: Int
    let columns: Int
    let images: [SavedCanvasImage]
    let backgroundColorHex: String
}

// MARK: - Undo State

struct CanvasState {
    let images: [CanvasImage]
    let rows: Int
    let columns: Int
    let backgroundColor: Color
}

// MARK: - Color Hex Extension

extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#FFFFFF" }
        let r = Int(components[0] * 255)
        let g = Int(components.count > 1 ? components[1] * 255 : components[0] * 255)
        let b = Int(components.count > 2 ? components[2] * 255 : components[0] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
