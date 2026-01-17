import SwiftUI

/// Font picker with preview list and weight selection
struct FontPickerView: View {
    @Binding var selectedFontFamily: String
    @Binding var selectedFontWeight: String
    @Environment(\.dismiss) var dismiss

    @State private var selectedFamily: FontFamily
    @State private var searchText: String = ""

    init(selectedFontFamily: Binding<String>, selectedFontWeight: Binding<String>) {
        self._selectedFontFamily = selectedFontFamily
        self._selectedFontWeight = selectedFontWeight

        // Initialize with current font
        let family = FontFamily.fontByName(selectedFontFamily.wrappedValue) ?? FontFamily.allFonts.first!
        self._selectedFamily = State(initialValue: family)
    }

    var filteredFonts: [FontFamily] {
        if searchText.isEmpty {
            return FontFamily.allFonts
        }
        return FontFamily.allFonts.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Font family list
                fontFamilyList

                Divider()

                // Font weight selection
                if selectedFamily.weights.count > 1 {
                    fontWeightSection
                }
            }
            .navigationTitle(NSLocalizedString("Select Font", comment: "Font picker title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Done", comment: "Done button")) {
                        selectedFontFamily = selectedFamily.displayName
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: NSLocalizedString("Search fonts", comment: "Font search placeholder"))
        }
    }

    // MARK: - Font Family List

    private var fontFamilyList: some View {
        List(filteredFonts) { family in
            Button {
                selectedFamily = family
                // Auto-select default weight
                let defaultWeight = family.defaultWeight
                selectedFontWeight = defaultWeight.name
            } label: {
                HStack(spacing: 12) {
                    // Preview text
                    Text("Aa")
                        .font(fontForPreview(family))
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    // Font name and info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(family.displayName)
                            .font(.body)
                            .foregroundColor(.primary)

                        HStack(spacing: 8) {
                            if family.isVariableFont {
                                Text(NSLocalizedString("Variable", comment: "Variable font label"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if !family.isSystemFont {
                                Text(NSLocalizedString("Custom", comment: "Custom font label"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if family.weights.count > 1 {
                                Text("\(family.weights.count) weights")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    // Selection indicator
                    if selectedFamily.displayName == family.displayName {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }

    // MARK: - Font Weight Section

    private var fontWeightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("Font Weight", comment: "Font weight section title"))
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(selectedFamily.weights) { weight in
                        Button {
                            selectedFontWeight = weight.name
                        } label: {
                            VStack(spacing: 6) {
                                Text("Aa")
                                    .font(fontForWeight(weight, size: 24))
                                    .frame(width: 60, height: 50)

                                Text(weight.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 80)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedFontWeight == weight.name ? Color.blue.opacity(0.15) : Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedFontWeight == weight.name ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Helper Methods

    private func fontForPreview(_ family: FontFamily) -> Font {
        let weight = family.defaultWeight
        if family.isSystemFont && family.displayName == "SF Pro" {
            return .system(size: 22, weight: weight.weight)
        }
        return .custom(weight.postScriptName, size: 22)
    }

    private func fontForWeight(_ weight: FontWeight, size: CGFloat) -> Font {
        if selectedFamily.isSystemFont && selectedFamily.displayName == "SF Pro" {
            return .system(size: size, weight: weight.weight)
        }
        return .custom(weight.postScriptName, size: size)
    }
}
