import SwiftUI

// MARK: - Dimension Overrides
/// Stores custom line positions for slot resizing
struct DimensionOverrides: Codable, Equatable {
    /// Key: line override key (e.g., "h0.5000" for horizontal at y=0.5, "v0.5000" for vertical at x=0.5)
    /// Value: new position (0.0-1.0)
    var linePositions: [String: CGFloat] = [:]
    
    /// Get the overridden position for a line, or return nil if not overridden
    func position(for key: String) -> CGFloat? {
        linePositions[key]
    }
    
    /// Set the position for a line
    mutating func setPosition(_ position: CGFloat, for key: String) {
        linePositions[key] = position
    }
    
    /// Check if there are any overrides
    var isEmpty: Bool {
        linePositions.isEmpty
    }
}

struct LayoutConfiguration: Codable {
    var template: String // Template ID
    var aspectRatio: CGFloat = 4.0 / 5.0
    var outerBorderWidth: CGFloat = 10.0
    var innerSpacing: CGFloat = 5.0
    var cornerRadius: CGFloat = 0.0
    var backgroundColor: Color = .white
    var dimensionOverrides: DimensionOverrides = DimensionOverrides()
    
    // Predefined aspect ratios
    static let ratio1x1: CGFloat = 1.0
    static let ratio4x5: CGFloat = 4.0 / 5.0
    static let ratio16x9: CGFloat = 16.0 / 9.0
    static let ratio9x16: CGFloat = 9.0 / 16.0
    
    // MARK: - Codable Conformance
    enum CodingKeys: String, CodingKey {
        case template
        case aspectRatio
        case outerBorderWidth
        case innerSpacing
        case cornerRadius
        case backgroundColor
        case dimensionOverrides
    }
    
    init(template: String = "grid2x2", aspectRatio: CGFloat = 4.0 / 5.0, outerBorderWidth: CGFloat = 10.0, innerSpacing: CGFloat = 5.0, cornerRadius: CGFloat = 0.0, backgroundColor: Color = .white, dimensionOverrides: DimensionOverrides = DimensionOverrides()) {
        self.template = template
        self.aspectRatio = aspectRatio
        self.outerBorderWidth = outerBorderWidth
        self.innerSpacing = innerSpacing
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.dimensionOverrides = dimensionOverrides
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        template = try container.decode(String.self, forKey: .template)
        aspectRatio = try container.decode(CGFloat.self, forKey: .aspectRatio)
        outerBorderWidth = try container.decode(CGFloat.self, forKey: .outerBorderWidth)
        innerSpacing = try container.decode(CGFloat.self, forKey: .innerSpacing)
        cornerRadius = try container.decode(CGFloat.self, forKey: .cornerRadius)
        
        // Decode Color as RGBA
        let colorData = try container.decode(Data.self, forKey: .backgroundColor)
        if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            backgroundColor = Color(uiColor)
        } else {
            backgroundColor = .white
        }
        
        // Decode dimension overrides (optional for backward compatibility)
        dimensionOverrides = try container.decodeIfPresent(DimensionOverrides.self, forKey: .dimensionOverrides) ?? DimensionOverrides()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(template, forKey: .template)
        try container.encode(aspectRatio, forKey: .aspectRatio)
        try container.encode(outerBorderWidth, forKey: .outerBorderWidth)
        try container.encode(innerSpacing, forKey: .innerSpacing)
        try container.encode(cornerRadius, forKey: .cornerRadius)
        
        // Encode Color using UIColor and NSKeyedArchiver
        let uiColor = UIColor(backgroundColor)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .backgroundColor)
        
        // Encode dimension overrides
        try container.encode(dimensionOverrides, forKey: .dimensionOverrides)
    }
}

struct LayoutPhoto: Identifiable {
    let id = UUID()
    var image: UIImage?
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var version: Int = 0  // Increments on image change to trigger view updates

    var hasImage: Bool { image != nil }
}
