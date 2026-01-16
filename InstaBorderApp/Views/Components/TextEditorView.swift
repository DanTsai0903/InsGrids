import SwiftUI

/// Text editor view for creating and editing text elements
struct TextEditorView: View {
    @Binding var textElement: TextElement?
    var onSave: (TextElement) -> Void
    @Environment(\.dismiss) var dismiss
    
    // Local state for editing
    @State private var text: String = ""
    @State private var selectedFont: String = "SF Pro Text"
    @State private var fontSize: CGFloat = 24
    @State private var textColor: Color = .black
    @State private var alignment: TextAlignment = .center
    @State private var backgroundType: BackgroundType = .none
    @State private var backgroundColor: Color = .white
    @State private var backgroundOpacity: Double = 1.0
    
    enum BackgroundType: String, CaseIterable {
        case none = "None"
        case solid = "Solid"
        case semiTransparent = "Semi-transparent"
    }
    
    init(textElement: Binding<TextElement?>, onSave: @escaping (TextElement) -> Void) {
        self._textElement = textElement
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Live preview
                    previewSection
                    
                    Divider()
                    
                    // Text input
                    textInputSection
                    
                    // Font selection
                    fontSection
                    
                    // Size and color
                    sizeAndColorSection
                    
                    // Alignment
                    alignmentSection
                    
                    // Background
                    backgroundSection
                }
                .padding()
            }
            .navigationTitle(textElement == nil 
                ? NSLocalizedString("Add Text", comment: "Add text title")
                : NSLocalizedString("Edit Text", comment: "Edit text title")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Done", comment: "Done button")) {
                        saveAndDismiss()
                    }
                    .disabled(text.isEmpty)
                }
            }
            .onAppear {
                setupInitialState()
            }
        }
    }
    
    // MARK: - Preview Section
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("Preview", comment: "Preview label"))
                .font(.headline)
            
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 120)
                    .cornerRadius(12)
                
                // Text preview with background
                Group {
                    if backgroundType != .none {
                        Text(text.isEmpty ? NSLocalizedString("Double tap to edit", comment: "Placeholder text") : text)
                            .font(fontForName(selectedFont).weight(.regular))
                            .font(.system(size: min(fontSize, 32)))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(alignment)
                            .padding(8)
                            .background(
                                backgroundColor.opacity(backgroundType == .semiTransparent ? 0.5 : 1.0)
                            )
                            .cornerRadius(4)
                    } else {
                        Text(text.isEmpty ? NSLocalizedString("Double tap to edit", comment: "Placeholder text") : text)
                            .font(fontForName(selectedFont).weight(.regular))
                            .font(.system(size: min(fontSize, 32)))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(alignment)
                    }
                }
            }
        }
    }
    
    // MARK: - Text Input Section
    
    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("Text", comment: "Text label"))
                .font(.headline)
            
            TextEditor(text: $text)
                .frame(minHeight: 80, maxHeight: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Font Section
    
    private var fontSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("Font", comment: "Font label"))
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TextElement.availableFonts, id: \.self) { fontName in
                        Button {
                            selectedFont = fontName
                        } label: {
                            Text("Aa")
                                .font(fontForName(fontName))
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedFont == fontName ? Color.blue.opacity(0.2) : Color(.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedFont == fontName ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Size and Color Section
    
    private var sizeAndColorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("Size", comment: "Size label"))
                        .font(.headline)
                    
                    HStack {
                        Text("\(Int(fontSize))pt")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 45, alignment: .leading)
                        
                        Slider(value: $fontSize, in: 12...72, step: 1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(NSLocalizedString("Color", comment: "Color label"))
                        .font(.headline)
                    
                    ColorPicker("", selection: $textColor)
                        .labelsHidden()
                }
            }
        }
    }
    
    // MARK: - Alignment Section
    
    private var alignmentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("Alignment", comment: "Alignment label"))
                .font(.headline)
            
            Picker("", selection: $alignment) {
                Image(systemName: "text.alignleft")
                    .tag(TextAlignment.leading)
                Image(systemName: "text.aligncenter")
                    .tag(TextAlignment.center)
                Image(systemName: "text.alignright")
                    .tag(TextAlignment.trailing)
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Background Section
    
    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("Background", comment: "Background label"))
                .font(.headline)
            
            Picker("", selection: $backgroundType) {
                Text(NSLocalizedString("None", comment: "None option")).tag(BackgroundType.none)
                Text(NSLocalizedString("Solid", comment: "Solid option")).tag(BackgroundType.solid)
                Text(NSLocalizedString("Semi-transparent", comment: "Semi-transparent option")).tag(BackgroundType.semiTransparent)
            }
            .pickerStyle(.segmented)
            
            if backgroundType != .none {
                HStack {
                    Text(NSLocalizedString("Background Color", comment: "Background color label"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    ColorPicker("", selection: $backgroundColor)
                        .labelsHidden()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func fontForName(_ name: String) -> Font {
        switch name {
        case "SF Pro Text": return .system(.body, design: .default)
        case "Helvetica Neue": return .custom("Helvetica Neue", size: 16)
        case "Georgia": return .custom("Georgia", size: 16)
        case "Courier New": return .custom("Courier New", size: 16)
        case "Times New Roman": return .custom("Times New Roman", size: 16)
        case "Arial": return .custom("Arial", size: 16)
        case "Menlo": return .custom("Menlo", size: 16)
        default: return .system(.body)
        }
    }
    
    private func setupInitialState() {
        if let element = textElement {
            text = element.text
            selectedFont = element.font
            fontSize = element.fontSize
            textColor = element.color
            alignment = element.alignment
            
            if let bgColor = element.backgroundColor {
                backgroundColor = bgColor
                if element.backgroundOpacity < 1.0 {
                    backgroundType = .semiTransparent
                } else {
                    backgroundType = .solid
                }
            } else {
                backgroundType = .none
            }
        } else {
            text = ""
        }
    }
    
    private func saveAndDismiss() {
        var element = textElement ?? TextElement(text: text)
        
        element.text = text
        element.font = selectedFont
        element.fontSize = fontSize
        element.color = textColor
        element.alignment = alignment
        
        switch backgroundType {
        case .none:
            element.backgroundColor = nil
            element.backgroundOpacity = 0
        case .solid:
            element.backgroundColor = backgroundColor
            element.backgroundOpacity = 1.0
        case .semiTransparent:
            element.backgroundColor = backgroundColor
            element.backgroundOpacity = 0.5
        }
        
        onSave(element)
        dismiss()
    }
}
