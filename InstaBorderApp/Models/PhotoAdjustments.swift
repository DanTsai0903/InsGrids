import Foundation

/// Stores photo adjustment parameters for CoreImage filter chain
/// Non-destructive: these values are stored as a "recipe" and applied during preview/export
struct PhotoAdjustments: Codable, Equatable {
    /// Brightness adjustment (-0.5 to 0.5, default 0)
    var brightness: Double = 0.0
    
    /// Contrast adjustment (0.5 to 1.5, default 1.0)
    var contrast: Double = 1.0
    
    /// Saturation adjustment (0.0 to 2.0, default 1.0)
    var saturation: Double = 1.0
    
    /// Exposure adjustment in EV (-2.0 to 2.0, default 0)
    var exposure: Double = 0.0
    
    /// Color temperature/warmth (-1.0 cool to 1.0 warm, default 0)
    var warmth: Double = 0.0
    
    /// Vignette intensity (0.0 to 2.0, default 0)
    var vignette: Double = 0.0
    
    /// Sharpness (0.0 to 1.0, default 0)
    var sharpness: Double = 0.0
    
    /// Optional filter preset name (e.g., "CIPhotoEffectMono")
    var filterName: String? = nil
    
    /// Check if any adjustments have been made (not default)
    var hasAdjustments: Bool {
        brightness != 0.0 ||
        contrast != 1.0 ||
        saturation != 1.0 ||
        exposure != 0.0 ||
        warmth != 0.0 ||
        vignette != 0.0 ||
        sharpness != 0.0 ||
        filterName != nil
    }
    
    /// Reset all adjustments to defaults
    mutating func reset() {
        brightness = 0.0
        contrast = 1.0
        saturation = 1.0
        exposure = 0.0
        warmth = 0.0
        vignette = 0.0
        sharpness = 0.0
        filterName = nil
    }
    
    /// Available filter presets using CIPhotoEffect filters
    /// name: CIFilter name, localizationKey: key for NSLocalizedString
    static let availableFilters: [(name: String, localizationKey: String)] = [
        ("CIPhotoEffectChrome", "filter.chrome"),
        ("CIPhotoEffectFade", "filter.fade"),
        ("CIPhotoEffectInstant", "filter.instant"),
        ("CIPhotoEffectMono", "filter.mono"),
        ("CIPhotoEffectNoir", "filter.noir"),
        ("CIPhotoEffectProcess", "filter.process"),
        ("CIPhotoEffectTonal", "filter.tonal"),
        ("CIPhotoEffectTransfer", "filter.transfer")
    ]
}
