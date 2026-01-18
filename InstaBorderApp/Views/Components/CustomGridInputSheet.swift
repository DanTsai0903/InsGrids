import SwiftUI

struct CustomGridInputSheet: View {
    @Binding var isPresented: Bool
    let onCreateGrid: (LayoutTemplate) -> Void
    
    @State private var columns: Int = 2
    @State private var rows: Int = 2
    @State private var selectedAspectRatio: AspectRatioPreset = .portrait4_5
    
    enum AspectRatioPreset: String, CaseIterable {
        case square1_1 = "1:1"
        case portrait4_5 = "4:5"
        case landscape5_4 = "5:4"
        case landscape16_9 = "16:9"
        case portrait9_16 = "9:16"
        
        var ratio: CGFloat {
            switch self {
            case .square1_1: return 1.0
            case .portrait4_5: return 4.0 / 5.0
            case .landscape5_4: return 5.0 / 4.0
            case .landscape16_9: return 16.0 / 9.0
            case .portrait9_16: return 9.0 / 16.0
            }
        }
    }
    
    // Calculate preview size to fit within maxSize while maintaining aspect ratio
    private var previewSize: CGSize {
        let maxSize: CGFloat = 200
        let ratio = selectedAspectRatio.ratio
        
        if ratio >= 1.0 {
            // Landscape or square: width is constrained
            let width = maxSize
            let height = maxSize / ratio
            return CGSize(width: width, height: height)
        } else {
            // Portrait: height is constrained
            let height = maxSize
            let width = maxSize * ratio
            return CGSize(width: width, height: height)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                Text(NSLocalizedString("customGrid.title", comment: "Custom Grid"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Input Controls
                VStack(spacing: 20) {
                    // Columns Stepper
                    HStack {
                        Text(NSLocalizedString("customGrid.columns", comment: "Columns"))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: { 
                                if columns > 1 { columns -= 1 }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(columns > 1 ? .blue : .gray)
                            }
                            .disabled(columns <= 1)
                            
                            Text("\(columns)")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(minWidth: 40)
                            
                            Button(action: { 
                                if columns < 30 { columns += 1 }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(columns < 30 ? .blue : .gray)
                            }
                            .disabled(columns >= 30)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Rows Stepper
                    HStack {
                        Text(NSLocalizedString("customGrid.rows", comment: "Rows"))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: { 
                                if rows > 1 { rows -= 1 }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(rows > 1 ? .blue : .gray)
                            }
                            .disabled(rows <= 1)
                            
                            Text("\(rows)")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(minWidth: 40)
                            
                            Button(action: { 
                                if rows < 30 { rows += 1 }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(rows < 30 ? .blue : .gray)
                            }
                            .disabled(rows >= 30)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Aspect Ratio Selector
                VStack(spacing: 12) {
                    Text(NSLocalizedString("customGrid.aspectRatio", comment: "Aspect Ratio"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        ForEach(AspectRatioPreset.allCases, id: \.self) { preset in
                            Button(action: {
                                selectedAspectRatio = preset
                            }) {
                                Text(preset.rawValue)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedAspectRatio == preset ? Color.blue : Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Preview
                VStack(spacing: 12) {
                    Text(NSLocalizedString("customGrid.preview", comment: "Preview"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    GridPreview(columns: columns, rows: rows, aspectRatio: selectedAspectRatio.ratio)
                        .frame(width: previewSize.width, height: previewSize.height)
                }
                
                // Slot Count Info
                Text("\(columns) × \(rows) = \(columns * rows) \(NSLocalizedString("customGrid.slots", comment: "slots"))")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        let template = LayoutTemplate.customGrid(rows: rows, columns: columns)
                        onCreateGrid(template)
                        isPresented = false
                    }) {
                        Text(NSLocalizedString("customGrid.create", comment: "Create Grid"))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text(NSLocalizedString("customGrid.cancel", comment: "Cancel"))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

/// Mini grid preview visualization
struct GridPreview: View {
    let columns: Int
    let rows: Int
    let aspectRatio: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let cellWidth = size.width / CGFloat(columns)
            let cellHeight = size.height / CGFloat(rows)
            
            ZStack {
                Color.gray.opacity(0.1)
                
                // Draw grid lines
                Path { path in
                    // Vertical lines
                    for col in 1..<columns {
                        let x = CGFloat(col) * cellWidth
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    
                    // Horizontal lines
                    for row in 1..<rows {
                        let y = CGFloat(row) * cellHeight
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                
                // Draw border
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
