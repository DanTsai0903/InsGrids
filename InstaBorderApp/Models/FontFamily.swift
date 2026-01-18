import SwiftUI
import UIKit

/// Font weight/style variant
struct FontWeight: Identifiable, Hashable {
    let id = UUID()
    let name: String           // Display name (e.g., "Regular", "Bold")
    let postScriptName: String // PostScript name for UIFont
    let weight: Font.Weight    // SwiftUI font weight

    /// Convert SwiftUI Font.Weight to UIFont.Weight
    var uiWeight: UIFont.Weight {
        switch weight {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }

    static let regular = Font.Weight.regular
    static let light = Font.Weight.light
    static let bold = Font.Weight.bold
}

/// Font family with multiple weights/styles
struct FontFamily: Identifiable {
    let id = UUID()
    let displayName: String    // User-facing name (e.g., "LXGW WenKai TC")
    let weights: [FontWeight]  // Available weights
    let isSystemFont: Bool
    let isVariableFont: Bool   // True for variable fonts

    var defaultWeight: FontWeight {
        weights.first { $0.name == "Regular" } ?? weights.first!
    }

    // MARK: - System Fonts

    static let systemFonts: [FontFamily] = [
        FontFamily(
            displayName: "SF Pro",
            weights: [
                FontWeight(name: "Light", postScriptName: "", weight: .light),
                FontWeight(name: "Regular", postScriptName: "", weight: .regular),
                FontWeight(name: "Medium", postScriptName: "", weight: .medium),
                FontWeight(name: "Semibold", postScriptName: "", weight: .semibold),
                FontWeight(name: "Bold", postScriptName: "", weight: .bold),
            ],
            isSystemFont: true,
            isVariableFont: false
        ),
        FontFamily(
            displayName: "Helvetica Neue",
            weights: [
                FontWeight(name: "Light", postScriptName: "HelveticaNeue-Light", weight: .light),
                FontWeight(name: "Regular", postScriptName: "HelveticaNeue", weight: .regular),
                FontWeight(name: "Medium", postScriptName: "HelveticaNeue-Medium", weight: .medium),
                FontWeight(name: "Bold", postScriptName: "HelveticaNeue-Bold", weight: .bold),
            ],
            isSystemFont: true,
            isVariableFont: false
        ),
        FontFamily(
            displayName: "Georgia",
            weights: [
                FontWeight(name: "Regular", postScriptName: "Georgia", weight: .regular),
                FontWeight(name: "Bold", postScriptName: "Georgia-Bold", weight: .bold),
            ],
            isSystemFont: true,
            isVariableFont: false
        ),
        FontFamily(
            displayName: "Arial",
            weights: [
                FontWeight(name: "Regular", postScriptName: "ArialMT", weight: .regular),
                FontWeight(name: "Bold", postScriptName: "Arial-BoldMT", weight: .bold),
            ],
            isSystemFont: true,
            isVariableFont: false
        ),
    ]

    // MARK: - Custom Fonts

    static let customFonts: [FontFamily] = [
        FontFamily(
            displayName: "Cactus Classical Serif",
            weights: [
                FontWeight(name: "Regular", postScriptName: "CactusClassicalSerif-Regular", weight: .regular),
            ],
            isSystemFont: false,
            isVariableFont: false
        ),
        FontFamily(
            displayName: "Chocolate Classical Sans",
            weights: [
                FontWeight(name: "Regular", postScriptName: "ChocolateClassicalSans-Regular", weight: .regular),
            ],
            isSystemFont: false,
            isVariableFont: false
        ),
        FontFamily(
            displayName: "Chiron GoRound TC",
            weights: [
                FontWeight(name: "Variable", postScriptName: "ChironGoRoundTC-ExtraLight", weight: .regular),
            ],
            isSystemFont: false,
            isVariableFont: true
        ),
        FontFamily(
            displayName: "Chiron Hei HK",
            weights: [
                FontWeight(name: "Variable", postScriptName: "ChironHeiHK-ExtraLight", weight: .regular),
                FontWeight(name: "Variable Italic", postScriptName: "ChironHeiHK-ExtraLightItalic", weight: .regular),
            ],
            isSystemFont: false,
            isVariableFont: true
        ),
        FontFamily(
            displayName: "Chiron Sung HK",
            weights: [
                FontWeight(name: "Variable", postScriptName: "ChironSungHK-ExtraLight", weight: .regular),
                FontWeight(name: "Variable Italic", postScriptName: "ChironSungHK-ExtraLightItalic", weight: .regular),
            ],
            isSystemFont: false,
            isVariableFont: true
        ),
        FontFamily(
            displayName: "LXGW WenKai TC",
            weights: [
                FontWeight(name: "Light", postScriptName: "LXGWWenKaiTC-Light", weight: .light),
                FontWeight(name: "Regular", postScriptName: "LXGWWenKaiTC-Regular", weight: .regular),
                FontWeight(name: "Bold", postScriptName: "LXGWWenKaiTC-Bold", weight: .bold),
            ],
            isSystemFont: false,
            isVariableFont: false
        ),
        FontFamily(
            displayName: "LXGW WenKai Mono TC",
            weights: [
                FontWeight(name: "Light", postScriptName: "LXGWWenKaiMonoTC-Light", weight: .light),
                FontWeight(name: "Regular", postScriptName: "LXGWWenKaiMonoTC-Regular", weight: .regular),
                FontWeight(name: "Bold", postScriptName: "LXGWWenKaiMonoTC-Bold", weight: .bold),
            ],
            isSystemFont: false,
            isVariableFont: false
        ),
    ]

    // MARK: - All Fonts

    static let allFonts: [FontFamily] = systemFonts + customFonts

    // MARK: - Helper Methods

    /// Get font by display name
    static func fontByName(_ name: String) -> FontFamily? {
        allFonts.first { $0.displayName == name }
    }

    /// Get FontWeight by names
    func weightByName(_ weightName: String) -> FontWeight? {
        weights.first { $0.name == weightName }
    }
}
