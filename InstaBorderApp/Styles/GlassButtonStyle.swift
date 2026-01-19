import SwiftUI

// MARK: - Primary Glass Button Style

/// A button style with glass/material effect for primary actions
struct GlassPrimaryButtonStyle: ButtonStyle {
    var width: CGFloat = 220
    var height: CGFloat = 56

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: width, height: height)
            .background(.thinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(.white.opacity(0.4), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Secondary Glass Button Style

/// A button style with lighter glass effect for secondary actions
struct GlassSecondaryButtonStyle: ButtonStyle {
    var width: CGFloat = 220
    var height: CGFloat = 56

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: width, height: height)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Toolbar Glass Button Style

/// A compact button style for toolbar actions
struct GlassToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style

/// A circular button style for icon-only buttons
struct GlassIconButtonStyle: ButtonStyle {
    var size: CGFloat = 32

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(.ultraThinMaterial, in: Circle())
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == GlassPrimaryButtonStyle {
    static var glassPrimary: GlassPrimaryButtonStyle { GlassPrimaryButtonStyle() }

    static func glassPrimary(width: CGFloat = 220, height: CGFloat = 56) -> GlassPrimaryButtonStyle {
        GlassPrimaryButtonStyle(width: width, height: height)
    }
}

extension ButtonStyle where Self == GlassSecondaryButtonStyle {
    static var glassSecondary: GlassSecondaryButtonStyle { GlassSecondaryButtonStyle() }

    static func glassSecondary(width: CGFloat = 220, height: CGFloat = 56) -> GlassSecondaryButtonStyle {
        GlassSecondaryButtonStyle(width: width, height: height)
    }
}

extension ButtonStyle where Self == GlassToolbarButtonStyle {
    static var glassToolbar: GlassToolbarButtonStyle { GlassToolbarButtonStyle() }
}

extension ButtonStyle where Self == GlassIconButtonStyle {
    static var glassIcon: GlassIconButtonStyle { GlassIconButtonStyle() }

    static func glassIcon(size: CGFloat = 32) -> GlassIconButtonStyle {
        GlassIconButtonStyle(size: size)
    }
}
