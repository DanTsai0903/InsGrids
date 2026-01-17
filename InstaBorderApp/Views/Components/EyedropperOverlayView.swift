import SwiftUI

/// Eyedropper overlay for picking colors from canvas
struct EyedropperOverlayView: View {
    let canvasSnapshot: UIImage?
    @Binding var selectedColor: Color
    var onColorPicked: (Color) -> Void
    var onCancel: () -> Void
    
    @State private var currentPosition: CGPoint = .zero
    @State private var isDragging: Bool = false
    @State private var sampledColor: Color = .white
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Canvas snapshot as background
                if let snapshot = canvasSnapshot {
                    Image(uiImage: snapshot)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Color picker pin
                if isDragging {
                    ColorPickerPin(color: sampledColor)
                        .position(x: currentPosition.x, y: currentPosition.y - 50)
                }
                
                // Instruction overlay at top
                VStack {
                    HStack {
                        Text(NSLocalizedString("拖曳選擇顏色", comment: "Drag to pick color"))
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button {
                            onCancel()
                        } label: {
                            Text(NSLocalizedString("取消", comment: "Cancel"))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(16)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        currentPosition = value.location
                        
                        // Sample color at this position
                        if let snapshot = canvasSnapshot {
                            sampledColor = getColor(at: value.location, in: snapshot, viewSize: geometry.size)
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        // Confirm the color
                        if let snapshot = canvasSnapshot {
                            let pickedColor = getColor(at: value.location, in: snapshot, viewSize: geometry.size)
                            onColorPicked(pickedColor)
                        } else {
                            // Fallback to prevent stuck UI
                            onCancel()
                        }
                    }
            )
        }
        .ignoresSafeArea()
    }
    
    /// Get color from image at specified point
    private func getColor(at point: CGPoint, in image: UIImage, viewSize: CGSize) -> Color {
        // Calculate the scale to fit image in view
        let imageSize = image.size
        let scale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        let offsetX = (viewSize.width - scaledWidth) / 2
        let offsetY = (viewSize.height - scaledHeight) / 2
        
        // Convert view point to image point
        let imageX = (point.x - offsetX) / scale
        let imageY = (point.y - offsetY) / scale
        
        // Clamp to image bounds
        let clampedX = max(0, min(imageX, imageSize.width - 1))
        let clampedY = max(0, min(imageY, imageSize.height - 1))
        
        // Get pixel color
        guard let cgImage = image.cgImage else { return .white }
        
        let pixelX = Int(clampedX)
        let pixelY = Int(clampedY)
        
        guard let pixelData = cgImage.dataProvider?.data else { return .white }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        let pixelIndex = pixelY * bytesPerRow + pixelX * bytesPerPixel
        
        // Get RGB values (handle different pixel formats)
        let r, g, b: CGFloat
        if cgImage.bitsPerPixel == 32 {
            r = CGFloat(data[pixelIndex]) / 255.0
            g = CGFloat(data[pixelIndex + 1]) / 255.0
            b = CGFloat(data[pixelIndex + 2]) / 255.0
        } else {
            r = CGFloat(data[pixelIndex]) / 255.0
            g = r
            b = r
        }
        
        return Color(red: r, green: g, blue: b)
    }
}

/// Pin marker showing the sampled color
struct ColorPickerPin: View {
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            // Circle showing color
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Pin point
            Triangle()
                .fill(Color.white)
                .frame(width: 16, height: 12)
                .offset(y: -2)
        }
    }
}

/// Triangle shape for pin point
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    EyedropperOverlayView(
        canvasSnapshot: nil,
        selectedColor: .constant(.white),
        onColorPicked: { _ in },
        onCancel: {}
    )
    .background(Color.gray)
}
