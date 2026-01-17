import SwiftUI

/// Custom color palette view with preset colors and eyedropper
struct CustomColorPaletteView: View {
    @Binding var selectedColor: Color
    var onEyedropperTap: () -> Void
    
    // Preset color palettes
    private let basicColors: [Color] = [
        .white, .black, Color(white: 0.5),
        .blue, Color(red: 0.2, green: 0.6, blue: 1.0),
        .green, Color(red: 0.3, green: 0.8, blue: 0.3),
        .yellow, .orange,
        .red, .pink, .purple
    ]
    
    private let warmColors: [Color] = [
        .red, Color(red: 1.0, green: 0.4, blue: 0.4),
        .orange, Color(red: 1.0, green: 0.7, blue: 0.5),
        Color(red: 1.0, green: 0.85, blue: 0.5), // gold
        Color(red: 0.6, green: 0.3, blue: 0.1), // brown
        Color(red: 0.8, green: 0.6, blue: 0.4), // tan
        Color(red: 0.5, green: 0.1, blue: 0.1), // maroon
        Color(red: 0.98, green: 0.5, blue: 0.45), // salmon
        Color(red: 0.5, green: 0.5, blue: 0.0), // olive
        Color(red: 0.4, green: 0.26, blue: 0.13), // dark brown
        Color(red: 0.0, green: 0.4, blue: 0.2) // forest green
    ]
    
    private let neutralColors: [Color] = [
        Color(white: 1.0),
        Color(white: 0.9),
        Color(white: 0.8),
        Color(white: 0.7),
        Color(white: 0.6),
        Color(white: 0.5),
        Color(white: 0.4),
        Color(white: 0.3),
        Color(white: 0.2),
        Color(white: 0.1),
        Color(white: 0.0)
    ]
    
    @State private var currentPage: Int = 0
    
    private var currentPalette: [Color] {
        switch currentPage {
        case 0: return basicColors
        case 1: return warmColors
        case 2: return neutralColors
        default: return basicColors
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Color palette row
            HStack(spacing: 12) {
                // Eyedropper button
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
                
                // Scrollable color palette
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(currentPalette.enumerated()), id: \.offset) { index, color in
                            colorCircle(color: color)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal, 16)
            
            // Page indicators
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { page in
                    Circle()
                        .fill(page == currentPage ? Color.white : Color.white.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentPage = page
                            }
                        }
                }
            }
        }
        .padding(.vertical, 12)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width < 0 {
                        // Swipe left - next page
                        withAnimation {
                            currentPage = min(currentPage + 1, 2)
                        }
                    } else if value.translation.width > 0 {
                        // Swipe right - previous page
                        withAnimation {
                            currentPage = max(currentPage - 1, 0)
                        }
                    }
                }
        )
    }
    
    private func colorCircle(color: Color) -> some View {
        Button {
            selectedColor = color
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                
                // Selection indicator
                if colorsAreEqual(color, selectedColor) {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 32, height: 32)
                }
                
                // Border for light colors
                if isLightColor(color) {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: 32, height: 32)
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
        return luminance > 0.8
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
