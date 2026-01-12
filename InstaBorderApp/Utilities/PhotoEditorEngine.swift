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
        
        // 1. Exposure (Global exposure)
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
        
        // 3. Contrast & Saturation (Removed Brightness)
        if adjustments.contrast != 1.0 || adjustments.saturation != 1.0 {
            let filter = CIFilter.colorControls()
            filter.inputImage = output
            filter.contrast = Float(adjustments.contrast)
            filter.saturation = Float(adjustments.saturation)
            output = filter.outputImage ?? output
        }
        
        // 4. Tone Curve (Highlights, Shadows, Whites, Blacks)
        if adjustments.highlights != 0.0 || adjustments.shadows != 0.0 || adjustments.whites != 0.0 || adjustments.blacks != 0.0 {
            // Mapping Logic:
            // Blacks: Affects point (0.0), shifting Y based on value
            // Shadows: Affects point (0.25), shifting Y
            // Midtone: Fixed at (0.5, 0.5)
            // Highlights: Affects point (0.75), shifting Y
            // Whites: Affects point (1.0), shifting Y (clipping point)
            
            // Scale factors (tuned for UX feel)
            let blacksOffset = adjustments.blacks * 0.15
            let shadowsOffset = adjustments.shadows * 0.15
            let highlightsOffset = adjustments.highlights * 0.15
            let whitesOffset = adjustments.whites * 0.15 // Whites usually effectively clips or dims
            
            // CIFilterBuiltins expects CGPoint, not CIVector
            let p0 = CGPoint(x: 0.0, y: max(0.0, 0.0 + blacksOffset)) // Clamp blacks >= 0
            let p1 = CGPoint(x: 0.25, y: 0.25 + shadowsOffset)
            let p2 = CGPoint(x: 0.5, y: 0.5) // Anchor mid
            let p3 = CGPoint(x: 0.75, y: 0.75 + highlightsOffset)
            let p4 = CGPoint(x: 1.0, y: max(0.0, 1.0 + whitesOffset))
            
            let filter = CIFilter.toneCurve()
            filter.inputImage = output
            filter.point0 = p0
            filter.point1 = p1
            filter.point2 = p2
            filter.point3 = p3
            filter.point4 = p4
            output = filter.outputImage ?? output
        }
        
        // 5. Vignette (Post-tone mapping)
        if adjustments.vignette > 0.0 {
            let filter = CIFilter.vignette()
            filter.inputImage = output
            filter.intensity = Float(adjustments.vignette)
            filter.radius = Float(min(output.extent.width, output.extent.height) / 2)
            output = filter.outputImage ?? output
        }
        
        // 6. Sharpness
        if adjustments.sharpness > 0.0 {
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = output
            filter.sharpness = Float(adjustments.sharpness * 2.0) // Scale to 0-2 range
            output = filter.outputImage ?? output
        }
        
        // 7. Preset Filter (e.g., CIPhotoEffectMono)
        if let filterName = adjustments.filterName,
           let filter = CIFilter(name: filterName) {
            
            filter.setValue(output, forKey: kCIInputImageKey)
            
            if let filtered = filter.outputImage {
                // Apply intensity if less than 1.0
                if adjustments.filterIntensity < 1.0 {
                    // Mix filtered result with original (output) based on intensity
                    // CIDissolveTransition: t=0 is source(image), t=1 is target
                    // We want: t=0 -> output (unfiltered), t=1 -> filtered
                    let blender = CIFilter.dissolveTransition()
                    blender.inputImage = output         // Start state (0.0)
                    blender.targetImage = filtered      // End state (1.0)
                    blender.time = Float(adjustments.filterIntensity)
                    output = blender.outputImage ?? filtered
                } else {
                    output = filtered
                }
            }
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
