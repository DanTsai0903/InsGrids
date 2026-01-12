import SwiftUI
import PhotosUI
import Combine

class PhotoEditorViewModel: ObservableObject {
    @Published var processedThumbnails: [UIImage] = []
    @Published var configuration = BorderConfiguration()
    @Published var isProcessing = false
    @Published var adjustments: [PhotoAdjustments] = []
    
    private var originalImages: [UIImage] = []
    private var thumbnails: [UIImage] = []
    private let thumbnailSize: CGFloat = 200
    
    func addImages(_ images: [UIImage]) {
        self.originalImages = images
        self.adjustments = Array(repeating: PhotoAdjustments(), count: images.count)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let thumbs = images.map { self.createThumbnail($0) }
            DispatchQueue.main.async {
                self.thumbnails = thumbs
                self.processAllThumbnails()
            }
        }
    }
    
    private func createThumbnail(_ image: UIImage) -> UIImage {
        return resizeImage(image, maxDimension: thumbnailSize)
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        let scale = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func updateConfiguration(_ newConfig: BorderConfiguration) {
        self.configuration = newConfig
        processAllThumbnails()
    }
    
    func processAllThumbnails() {
        guard !thumbnails.isEmpty else { return }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            let config = self.configuration
            let currentAdjustments = self.adjustments
            
            // Ensure bounds
            let count = min(self.thumbnails.count, currentAdjustments.count)
            
            var processedResults: [UIImage] = []
            for i in 0..<count {
                autoreleasepool {
                    if let res = ImageProcessor.shared.processImage(self.thumbnails[i], configuration: config, adjustments: currentAdjustments[i]) {
                        processedResults.append(res)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.processedThumbnails = processedResults
            }
        }
    }
    
    // Serial processing: ONE image at a time to minimize memory usage
    func processAndSaveAll(completion: @escaping (Bool, Int) -> Void) {
        guard !originalImages.isEmpty else {
            completion(false, 0)
            return
        }
        
        DispatchQueue.main.async {
            self.isProcessing = true
        }
        
        let currentConfig = self.configuration
        let imageCount = self.originalImages.count
        
        // Process on background thread, one at a time
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(false, 0) }
                return
            }
            
            var successCount = 0
            
            for i in 0..<imageCount {
                // Use autoreleasepool to free memory after each image
                autoreleasepool {
                    let originalImage = self.originalImages[i]
                    let adjustment = i < self.adjustments.count ? self.adjustments[i] : nil
                    
                    // Process
                    guard let processed = ImageProcessor.shared.processImage(originalImage, configuration: currentConfig, adjustments: adjustment) else {
                        return // continue to next image
                    }
                    
                    // Save synchronously (wait for completion)
                    let semaphore = DispatchSemaphore(value: 0)
                    var saveSuccess = false
                    
                    ImageExporter.shared.saveImage(processed) { success, _ in
                        saveSuccess = success
                        semaphore.signal()
                    }
                    
                    // Wait up to 30 seconds
                    _ = semaphore.wait(timeout: .now() + 30)
                    
                    if saveSuccess {
                        successCount += 1
                    }
                }
                // Memory should be freed here for this iteration
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                completion(successCount == imageCount, successCount)
            }
        }
    }
    
    func clearAll() {
        originalImages.removeAll()
        thumbnails.removeAll()
        processedThumbnails.removeAll()
    }
    
    
    // MARK: - Photo Editor Helpers
    
    func getOriginalImage(at index: Int) -> UIImage? {
        guard index >= 0 && index < originalImages.count else { return nil }
        return originalImages[index]
    }
    
    func updateAdjustment(at index: Int, adjustment: PhotoAdjustments) {
        guard index >= 0 && index < adjustments.count else { return }
        adjustments[index] = adjustment
        // Trigger reprocessing of specific thumbnail for performance
        processThumbnail(at: index)
    }
    
    private func processThumbnail(at index: Int) {
        guard index < thumbnails.count else { return }
        let thumb = thumbnails[index]
        let config = configuration
        let adj = adjustments[index]
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            if let processed = ImageProcessor.shared.processImage(thumb, configuration: config, adjustments: adj) {
                DispatchQueue.main.async {
                    if index < self.processedThumbnails.count {
                        self.processedThumbnails[index] = processed
                    }
                }
            }
        }
    }
    
    var imageCount: Int {
        return originalImages.count
    }
}
