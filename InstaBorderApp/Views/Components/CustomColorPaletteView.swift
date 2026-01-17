import SwiftUI

/// Custom color palette view with preset colors and eyedropper
/// Redesigned with swipe-to-switch pages and smaller color circles in grid layout
struct CustomColorPaletteView: View {
    @Binding var selectedColor: Color
    var onEyedropperTap: () -> Void
    
    // Expanded color palettes with more colors for better selection
    private let basicColors: [Color] = [
        // Row 1: Whites and blacks
        .white, Color(white: 0.95), Color(white: 0.85), Color(white: 0.7),
        Color(white: 0.5), Color(white: 0.3), Color(white: 0.15), .black,
        // Row 2: Primary colors
        .red, Color(red: 1.0, green: 0.3, blue: 0.3), .orange, Color(red: 1.0, green: 0.7, blue: 0.3),
        .yellow, Color(red: 0.9, green: 0.9, blue: 0.4), .green, Color(red: 0.4, green: 0.8, blue: 0.4),
        // Row 3: Blues and purples
        .cyan, Color(red: 0.3, green: 0.7, blue: 1.0), .blue, Color(red: 0.4, green: 0.4, blue: 1.0),
        .purple, Color(red: 0.7, green: 0.4, blue: 1.0), .pink, Color(red: 1.0, green: 0.5, blue: 0.7)
    ]
    
    private let warmColors: [Color] = [
        // Row 1: Reds
        Color(red: 1.0, green: 0.0, blue: 0.0), Color(red: 0.9, green: 0.2, blue: 0.2),
        Color(red: 0.8, green: 0.3, blue: 0.3), Color(red: 0.7, green: 0.2, blue: 0.2),
        Color(red: 0.5, green: 0.1, blue: 0.1), Color(red: 0.4, green: 0.0, blue: 0.0),
        Color(red: 0.3, green: 0.0, blue: 0.0), Color(red: 0.2, green: 0.0, blue: 0.0),
        // Row 2: Oranges
        Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.6, blue: 0.2),
        Color(red: 1.0, green: 0.7, blue: 0.4), Color(red: 0.98, green: 0.5, blue: 0.45),
        Color(red: 0.9, green: 0.4, blue: 0.2), Color(red: 0.8, green: 0.4, blue: 0.1),
        Color(red: 0.6, green: 0.3, blue: 0.1), Color(red: 0.4, green: 0.2, blue: 0.1),
        // Row 3: Yellows and browns
        Color(red: 1.0, green: 0.85, blue: 0.0), Color(red: 1.0, green: 0.9, blue: 0.4),
        Color(red: 0.95, green: 0.85, blue: 0.5), Color(red: 0.85, green: 0.7, blue: 0.4),
        Color(red: 0.7, green: 0.5, blue: 0.3), Color(red: 0.55, green: 0.35, blue: 0.2),
        Color(red: 0.4, green: 0.26, blue: 0.13), Color(red: 0.3, green: 0.2, blue: 0.1)
    ]
    
    private let coolColors: [Color] = [
        // Row 1: Greens
        Color(red: 0.0, green: 0.8, blue: 0.0), Color(red: 0.2, green: 0.7, blue: 0.2),
        Color(red: 0.3, green: 0.6, blue: 0.3), Color(red: 0.0, green: 0.5, blue: 0.0),
        Color(red: 0.1, green: 0.4, blue: 0.2), Color(red: 0.0, green: 0.3, blue: 0.1),
        Color(red: 0.2, green: 0.4, blue: 0.3), Color(red: 0.3, green: 0.5, blue: 0.4),
        // Row 2: Blues
        Color(red: 0.0, green: 0.7, blue: 1.0), Color(red: 0.2, green: 0.6, blue: 1.0),
        Color(red: 0.3, green: 0.5, blue: 0.9), Color(red: 0.2, green: 0.4, blue: 0.8),
        Color(red: 0.1, green: 0.3, blue: 0.7), Color(red: 0.0, green: 0.2, blue: 0.6),
        Color(red: 0.0, green: 0.15, blue: 0.4), Color(red: 0.0, green: 0.1, blue: 0.3),
        // Row 3: Purples
        Color(red: 0.8, green: 0.4, blue: 1.0), Color(red: 0.7, green: 0.3, blue: 0.9),
        Color(red: 0.6, green: 0.2, blue: 0.8), Color(red: 0.5, green: 0.1, blue: 0.7),
        Color(red: 0.4, green: 0.1, blue: 0.6), Color(red: 0.3, green: 0.1, blue: 0.5),
        Color(red: 0.25, green: 0.05, blue: 0.4), Color(red: 0.2, green: 0.0, blue: 0.3)
    ]
    
    @State private var currentPage: Int = 0
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 8)
    
    var body: some View {
        VStack(spacing: 8) {
            // Swipeable color pages with eyedropper
            HStack(spacing: 12) {
                // Eyedropper button (icon only)
                Button {
                    onEyedropperTap()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "eyedropper")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 16)
                
                // Color grid section
                TabView(selection: $currentPage) {
                    colorGrid(colors: basicColors)
                        .tag(0)
                    
                    colorGrid(colors: warmColors)
                        .tag(1)
                    
                    colorGrid(colors: coolColors)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: 90)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func colorGrid(colors: [Color]) -> some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                colorCircle(color: color)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func colorCircle(color: Color) -> some View {
        Button {
            selectedColor = color
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 26, height: 26)
                
                // Selection indicator
                if colorsAreEqual(color, selectedColor) {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 26, height: 26)
                    Circle()
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        .frame(width: 30, height: 30)
                }
                
                // Border for light colors
                if isLightColor(color) && !colorsAreEqual(color, selectedColor) {
                    Circle()
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        .frame(width: 26, height: 26)
                }
            }
        }
    }
    
    // Check if two colors are approximately equal
    private func colorsAreEqual(_ c1: Color, _ c2: Color) -> Bool {
        let uic1 = UIColor(c1)
        let uic2 = UIColor(c2)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        uic1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uic2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let threshold: CGFloat = 0.05
        return abs(r1 - r2) < threshold && abs(g1 - g2) < threshold && abs(b1 - b2) < threshold
    }
    
    private func isLightColor(_ color: Color) -> Bool {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.85
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CustomColorPaletteView(
            selectedColor: .constant(.white),
            onEyedropperTap: {}
        )
    }
}
