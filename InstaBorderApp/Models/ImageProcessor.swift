import UIKit
import SwiftUI

class ImageProcessor {
    static let shared = ImageProcessor()
    
    // Maximum output pixels: 12MP = 12,000,000 pixels
    // This prevents memory crashes on devices like iPhone 13 mini
    private let maxOutputPixels: CGFloat = 12_000_000
    
    func processImage(_ image: UIImage, configuration: BorderConfiguration) -> UIImage? {
        let targetRatio = configuration.aspectRatio
        let scale = configuration.imageScale  // 0.3 to 1.0
        
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let originalRatio = originalWidth / originalHeight
        
        // Step 1: Calculate ideal output dimensions
        var outputWidth: CGFloat
        var outputHeight: CGFloat
        
        if originalRatio > targetRatio {
            outputWidth = originalWidth / scale
            outputHeight = outputWidth / targetRatio
        } else {
            outputHeight = originalHeight / scale
            outputWidth = outputHeight * targetRatio
        }
        
        // Ensure output can contain original
        outputWidth = max(outputWidth, originalWidth)
        outputHeight = max(outputHeight, originalHeight)
        
        // Step 2: CRITICAL - Limit total pixels to 12MP
        let totalPixels = outputWidth * outputHeight
        if totalPixels > maxOutputPixels {
            let reductionFactor = sqrt(maxOutputPixels / totalPixels)
            outputWidth *= reductionFactor
            outputHeight *= reductionFactor
        }
        
        // Round to whole pixels
        outputWidth = floor(outputWidth)
        outputHeight = floor(outputHeight)
        
        // Calculate the image size within the output (respecting scale and aspect ratio)
        var imageWidth: CGFloat
        var imageHeight: CGFloat
        
        // The image should fill `scale` fraction of the smaller dimension
        if originalRatio > targetRatio {
            // Image is wider, fit by width
            imageWidth = outputWidth * scale
            imageHeight = imageWidth / originalRatio
        } else {
            // Image is taller, fit by height  
            imageHeight = outputHeight * scale
            imageWidth = imageHeight * originalRatio
        }
        
        // Ensure image fits within output
        imageWidth = min(imageWidth, outputWidth)
        imageHeight = min(imageHeight, outputHeight)
        
        // Step 3: Create output canvas
        let outputSize = CGSize(width: outputWidth, height: outputHeight)
        
        // Use autorelease to clean up intermediate images
        return autoreleasepool {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1.0 // Don't multiply by screen scale
            let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)
            
            return renderer.image { context in
                // Fill background
                UIColor(configuration.borderColor).setFill()
                context.fill(CGRect(origin: .zero, size: outputSize))
                
                // Center the image
                let x = (outputWidth - imageWidth) / 2
                let y = (outputHeight - imageHeight) / 2
                
                image.draw(in: CGRect(x: x, y: y, width: imageWidth, height: imageHeight))
            }
        }
    }
}
