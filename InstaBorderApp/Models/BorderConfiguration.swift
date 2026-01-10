import SwiftUI

struct BorderConfiguration {
    var borderColor: Color = .white
    var aspectRatio: CGFloat = 4.0 / 5.0
    var imageScale: CGFloat = 1.0
    
    // Predefined aspect ratios
    static let ratio1x1: CGFloat = 1.0
    static let ratio4x5: CGFloat = 4.0 / 5.0
    static let ratio16x9: CGFloat = 16.0 / 9.0
    static let ratio9x16: CGFloat = 9.0 / 16.0
}
