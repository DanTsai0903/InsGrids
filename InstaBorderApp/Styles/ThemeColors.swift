import SwiftUI
import UIKit

// MARK: - Theme Colors

/// Semantic color constants for InsGrids iOS 26 Liquid Glass theme
enum ThemeColors {
    // MARK: - Backgrounds

    /// Primary background color (adapts to color scheme)
    static let background = Color(uiColor: .systemBackground)

    /// Secondary background for grouped content
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)

    /// Tertiary background for nested content
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)

    // MARK: - Text

    /// Primary text color
    static let primaryText = Color(uiColor: .label)

    /// Secondary text color for subtitles
    static let secondaryText = Color(uiColor: .secondaryLabel)

    /// Tertiary text color for hints
    static let tertiaryText = Color(uiColor: .tertiaryLabel)

    // MARK: - Accents

    /// App accent color
    static let accent = Color.blue

    /// Success color
    static let success = Color.green

    /// Warning color
    static let warning = Color.orange

    /// Error color
    static let error = Color.red

    // MARK: - Separators

    /// Standard separator color
    static let separator = Color(uiColor: .separator)

    /// Opaque separator color
    static let opaqueSeparator = Color(uiColor: .opaqueSeparator)

    // MARK: - Fills

    /// Primary fill color for UI elements
    static let primaryFill = Color(uiColor: .systemFill)

    /// Secondary fill color
    static let secondaryFill = Color(uiColor: .secondarySystemFill)

    /// Tertiary fill color
    static let tertiaryFill = Color(uiColor: .tertiarySystemFill)

    /// Quaternary fill color
    static let quaternaryFill = Color(uiColor: .quaternarySystemFill)
}

// MARK: - View Extensions for Common Backgrounds

extension View {
    /// Applies the standard app background with dark mode preference
    func appBackground() -> some View {
        self
            .background(ThemeColors.background.ignoresSafeArea())
            .preferredColorScheme(.dark)
    }

    /// Applies a material background suitable for toolbars
    func toolbarMaterial() -> some View {
        self.background(.bar)
    }

    /// Applies a glass overlay background
    func glassOverlay() -> some View {
        self.background(.ultraThinMaterial)
    }
}
