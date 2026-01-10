import SwiftUI

struct AspectRatioSlider: View {
    @Binding var ratio: CGFloat
    
    let ratios: [(String, CGFloat)] = [
        ("1:1", BorderConfiguration.ratio1x1),
        ("4:5", BorderConfiguration.ratio4x5),
        ("16:9", BorderConfiguration.ratio16x9),
        ("9:16", BorderConfiguration.ratio9x16)
    ]
    
    // Custom formatted ratios for display
    private func ratioString(for value: CGFloat) -> String {
        if let match = ratios.first(where: { abs($0.1 - value) < 0.01 }) {
            return match.0
        }
        return String(format: "%.2f", value)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("比例: \(ratioString(for: ratio))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ratios, id: \.0) { item in
                        Button(action: {
                            withAnimation {
                                ratio = item.1
                            }
                        }) {
                            Text(item.0)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(abs(ratio - item.1) < 0.01 ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(abs(ratio - item.1) < 0.01 ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
