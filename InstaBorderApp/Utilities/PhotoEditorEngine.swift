import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// Engine for applying photo adjustments using CoreImage
/// Uses Metal-accelerated CIContext for performance
final class PhotoEditorEngine {
    
    /// Shared CIContext for rendering (Metal-backed for performance)
    private let context: CIContext
    
    init() {
        // Use Metal for GPU-accelerated rendering
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.context = CIContext(mtlDevice: metalDevice, options: [
                .cacheIntermediates: true,  // Cache intermediate results for better performance
                .priorityRequestLow: false
            ])
        } else {
            // Fallback to CPU
            self.context = CIContext(options: [.useSoftwareRenderer: true])
        }
    }
    
    /// Apply adjustments to an image and return the result
    /// - Parameters:
    ///   - image: Source UIImage
    ///   - adjustments: PhotoAdjustments to apply
    /// - Returns: Processed UIImage, or original if processing fails
    func render(image: UIImage, adjustments: PhotoAdjustments) -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            return image
        }
        
        let processed = applyFilterChain(to: ciImage, adjustments: adjustments)
        
        // Render to CGImage
        guard let cgImage = context.createCGImage(processed, from: processed.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    /// Apply the full filter chain based on adjustments
    private func applyFilterChain(to input: CIImage, adjustments: PhotoAdjustments) -> CIImage {
        // Early return if no adjustments (performance optimization)
        guard adjustments.hasAdjustments else {
            return input
        }
        
        var output = input
        
        // 1. Exposure
        if adjustments.exposure != 0.0 {
            let filter = CIFilter.exposureAdjust()
            filter.inputImage = output
            filter.ev = Float(adjustments.exposure)
            output = filter.outputImage ?? output
        }
        
        // 2. Color Temperature (Warmth)
        if adjustments.warmth != 0.0 {
            let filter = CIFilter.temperatureAndTint()
            filter.inputImage = output
            // Neutral is (6500, 0), adjust temperature based on warmth
            let temp = 6500 + (adjustments.warmth * 2000) // Range: 4500 to 8500
            filter.neutral = CIVector(x: CGFloat(temp), y: 0)
            filter.targetNeutral = CIVector(x: 6500, y: 0)
            output = filter.outputImage ?? output
        }
        
        // 3. Basic Adjustments (Brightness, Contrast, Saturation)
        if adjustments.brightness != 0.0 || adjustments.contrast != 1.0 || adjustments.saturation != 1.0 {
            let filter = CIFilter.colorControls()
            filter.inputImage = output
            filter.brightness = Float(adjustments.brightness)
            filter.contrast = Float(adjustments.contrast)
            filter.saturation = Float(adjustments.saturation)
            output = filter.outputImage ?? output
        }
        
        // 4. Vignette
        if adjustments.vignette > 0.0 {
            let filter = CIFilter.vignette()
            filter.inputImage = output
            filter.intensity = Float(adjustments.vignette)
            filter.radius = Float(min(output.extent.width, output.extent.height) / 2)
            output = filter.outputImage ?? output
        }
        
        // 5. Sharpness
        if adjustments.sharpness > 0.0 {
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = output
            filter.sharpness = Float(adjustments.sharpness * 2.0) // Scale to 0-2 range
            output = filter.outputImage ?? output
        }
        
        // 6. Preset Filter (e.g., CIPhotoEffectMono)
        if let filterName = adjustments.filterName,
           let filter = CIFilter(name: filterName) {
            filter.setValue(output, forKey: kCIInputImageKey)
            output = filter.outputImage ?? output
        }
        
        return output
    }
    
    /// Generate a thumbnail preview for a filter
    /// - Parameters:
    ///   - image: Source image (should be small for performance)
    ///   - filterName: CIFilter name to apply
    /// - Returns: Filtered thumbnail
    func generateFilterThumbnail(image: UIImage, filterName: String) -> UIImage {
        var adjustments = PhotoAdjustments()
        adjustments.filterName = filterName
        return render(image: image, adjustments: adjustments)
    }
}
