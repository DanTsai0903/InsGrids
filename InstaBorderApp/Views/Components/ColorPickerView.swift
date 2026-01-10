import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    
    let presets: [Color] = [.white, .black]
    
    var body: some View {
        HStack(spacing: 20) {
            // Presets
            ForEach(presets, id: \.self) { color in
                ColorButton(color: color, isSelected: selectedColor == color) {
                    selectedColor = color
                }
            }
            
            // Custom Color Picker
            ColorPicker("", selection: $selectedColor)
                .labelsHidden()
                .frame(width: 44, height: 44)
                .padding(4)
                .background(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.vertical, 8)
    }
}

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: isSelected ? 3 : 0)
                        .scaleEffect(1.2)
                )
        }
    }
}
