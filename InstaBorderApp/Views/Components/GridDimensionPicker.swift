import SwiftUI

/// Picker component for selecting grid dimensions
struct GridDimensionPicker: View {
    @Binding var rows: Int
    @Binding var columns: Int
    var onSelect: () -> Void
    @Environment(\.dismiss) var dismiss
    
    // Quick presets (max 3 columns for quick select)
    private let presets: [(String, Int, Int)] = [
        ("1×3", 1, 3),
        ("2×3", 2, 3),
        ("3×3", 3, 3)
    ]
    
    // Maximum grid dimensions
    private let maxGridSize = 6
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text(NSLocalizedString("grid.dimension.title", comment: "Grid Size"))
                .font(.headline)
                .padding(.top, 20)
            
            // Quick presets
            Text(NSLocalizedString("grid.dimension.presets", comment: "Quick Presets"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(presets, id: \.0) { preset in
                    Button {
                        rows = preset.1
                        columns = preset.2
                        onSelect()
                        dismiss()
                    } label: {
                        Text(preset.0)
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background {
                                if isSelected(preset.1, preset.2) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.ultraThinMaterial)
                                }
                            }
                            .foregroundColor(isSelected(preset.1, preset.2) ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 10)
            
            // Custom input
            Text(NSLocalizedString("grid.dimension.custom", comment: "Custom Size"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                // Rows stepper
                VStack {
                    Text(NSLocalizedString("grid.dimension.rows", comment: "Rows"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Button {
                            if rows > 1 { rows -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(rows > 1 ? .blue : .gray)
                        }
                        .disabled(rows <= 1)
                        
                        Text("\(rows)")
                            .font(.title2.monospacedDigit())
                            .frame(width: 40)
                        
                        Button {
                            if rows < maxGridSize { rows += 1 }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(rows < maxGridSize ? .blue : .gray)
                        }
                        .disabled(rows >= maxGridSize)
                    }
                }
                
                Text("×")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                // Columns stepper
                VStack {
                    Text(NSLocalizedString("grid.dimension.columns", comment: "Columns"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Button {
                            if columns > 1 { columns -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(columns > 1 ? .blue : .gray)
                        }
                        .disabled(columns <= 1)
                        
                        Text("\(columns)")
                            .font(.title2.monospacedDigit())
                            .frame(width: 40)
                        
                        Button {
                            if columns < maxGridSize { columns += 1 }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(columns < maxGridSize ? .blue : .gray)
                        }
                        .disabled(columns >= maxGridSize)
                    }
                }
            }
            
            // Tile count indicator
            let tileCount = rows * columns
            Text(String(format: NSLocalizedString("grid.dimension.tiles", comment: "%d tiles"), tileCount))
                .font(.caption)
                .foregroundColor(tileCount > 16 ? .orange : .secondary)
            
            if tileCount > 16 {
                Text(NSLocalizedString("grid.dimension.warning", comment: "Large grids may take longer to export"))
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            // Apply button
            Button {
                onSelect()
                dismiss()
            } label: {
                Text(NSLocalizedString("button.apply", comment: "Apply"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(.bottom, 20)
    }
    
    private func isSelected(_ r: Int, _ c: Int) -> Bool {
        rows == r && columns == c
    }
}
