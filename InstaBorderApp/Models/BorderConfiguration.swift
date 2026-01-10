import SwiftUI

struct BorderConfiguration: Codable {
    var borderColor: Color = .white
    var aspectRatio: CGFloat = 4.0 / 5.0
    var imageScale: CGFloat = 1.0
    
    // Predefined aspect ratios
    static let ratio1x1: CGFloat = 1.0
    static let ratio4x5: CGFloat = 4.0 / 5.0
    static let ratio16x9: CGFloat = 16.0 / 9.0
    static let ratio9x16: CGFloat = 9.0 / 16.0

    // MARK: - Codable Conformance
    enum CodingKeys: String, CodingKey {
        case borderColor
        case aspectRatio
        case imageScale
    }

    init(borderColor: Color = .white, aspectRatio: CGFloat = 4.0 / 5.0, imageScale: CGFloat = 1.0) {
        self.borderColor = borderColor
        self.aspectRatio = aspectRatio
        self.imageScale = imageScale
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        aspectRatio = try container.decode(CGFloat.self, forKey: .aspectRatio)
        imageScale = try container.decode(CGFloat.self, forKey: .imageScale)
        
        // Decode Color as RGBA
        let colorData = try container.decode(Data.self, forKey: .borderColor)
        if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            borderColor = Color(uiColor)
        } else {
            borderColor = .white
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(aspectRatio, forKey: .aspectRatio)
        try container.encode(imageScale, forKey: .imageScale)
        
        // Encode Color using UIColor and NSKeyedArchiver
        let uiColor = UIColor(borderColor)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .borderColor)
    }
}
