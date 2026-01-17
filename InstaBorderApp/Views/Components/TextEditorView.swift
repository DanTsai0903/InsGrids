import SwiftUI

/// Text editor view for creating and editing text elements
struct TextEditorView: View {
    @Binding var textElement: TextElement?
    var onSave: (TextElement) -> Void
    var onDelete: (() -> Void)? = nil  // Called when text is cleared
    var onCancel: (() -> Void)? = nil  // Called when cancel button tapped
    
    // Local state for editing
    @State private var text: String = ""
    @State private var selectedFontFamily: String = "SF Pro"
    @State private var selectedFontWeight: String = "Regular"
    @State private var fontSize: CGFloat = 24
    @State private var textColor: Color = .white
    @State private var alignment: TextAlignment = .center
    @State private var backgroundType: BackgroundType = .none
    @State private var backgroundColor: Color = .white
    @State private var backgroundOpacity: Double = 1.0
    @State private var showFontPicker: Bool = false
    
    // Color picker states
    @State private var showColorPalette: Bool = false
    @State private var colorPickerMode: ColorPickerMode = .textColor
    @State private var isEyedropperActive: Bool = false
    var canvasSnapshot: UIImage?
    
    enum ColorPickerMode {
        case textColor
        case backgroundColor
    }
    
    // Focus state for keyboard
    @FocusState private var isTextFieldFocused: Bool
    
    enum BackgroundType: String, CaseIterable {
        case none = "None"
        case solid = "Solid"
        case semiTransparent = "Semi-transparent"
    }
    
    init(textElement: Binding<TextElement?>, canvasSnapshot: UIImage? = nil, onSave: @escaping (TextElement) -> Void, onDelete: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        self._textElement = textElement
        self.canvasSnapshot = canvasSnapshot
        self.onSave = onSave
        self.onDelete = onDelete
        self.onCancel = onCancel
    }
    
     var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark overlay background (canvas visible behind when using overlay presentation)
                // Use solid black when eyedropper is active to hide live canvas and only show snapshot
                Color.black.opacity(isEyedropperActive ? 1.0 : 0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Tap on background to dismiss keyboard and close color palette
                        isTextFieldFocused = false
                        showColorPalette = false
                    }
                
                    VStack(spacing: 0) {
                        // Top bar with Done button
                        HStack {
                            // Cancel button
                            Button {
                                onCancel?()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                            }
                            
                            Spacer()
                            
                            Button {
                                saveAndDismiss()
                            } label: {
                                Text(NSLocalizedString("完成", comment: "Done button"))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.blue)
                                    )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .opacity(isEyedropperActive ? 0 : 1) // Hide top bar
                        
                        Spacer()
                        
                        // Text input area with visible cursor
                        // When eyedropper is active, move to top-left
                        ZStack(alignment: isEyedropperActive ? .topLeading : .center) {
                            if isEyedropperActive {
                                Color.clear // Container expands
                            }
                            
                            // Styled text input with native blinking cursor
                            Group {
                                if backgroundType != .none {
                                    TextField("", text: $text, axis: .vertical)
                                        .font(fontForCurrentSelection(size: fontSize))
                                        .foregroundColor(textColor)
                                        .multilineTextAlignment(alignment)
                                        .tint(textColor) // Cursor color matches text
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(backgroundColor.opacity(backgroundType == .semiTransparent ? 0.5 : 1.0))
                                        .cornerRadius(4)
                                        .focused($isTextFieldFocused)
                                        .fixedSize(horizontal: true, vertical: false) // Wrap content only
                                } else {
                                    TextField("", text: $text, axis: .vertical)
                                        .font(fontForCurrentSelection(size: fontSize))
                                        .foregroundColor(textColor)
                                        .multilineTextAlignment(alignment)
                                        .tint(textColor) // Cursor color matches text
                                        .focused($isTextFieldFocused)
                                }
                            }
                            .frame(minWidth: text.isEmpty ? 2 : nil) // Just cursor width when empty
                            .onTapGesture {
                                // Tap on text to focus input
                                if !isEyedropperActive {
                                    isTextFieldFocused = true
                                    showColorPalette = false
                                }
                            }
                            .position(isEyedropperActive ? CGPoint(x: 100, y: 100) : CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                            // Note: Using position to force location during eyedropper mode
                            // Ideally we would use alignment, but position is more absolute
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill space to allow positioning
                        
                        Spacer()
                    
                    // Color palette (shown when color button tapped)
                    if showColorPalette {
                        VStack(spacing: 8) {
                            // Mode selector
                            HStack {
                                Text(colorPickerMode == .textColor ? 
                                     NSLocalizedString("文字顏色", comment: "Text color") : 
                                     NSLocalizedString("背景顏色", comment: "Background color"))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    showColorPalette = false
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            CustomColorPaletteView(
                                selectedColor: colorPickerMode == .textColor ? $textColor : $backgroundColor,
                                onEyedropperTap: {
                                    showColorPalette = false
                                    // TODO: Capture canvas snapshot and show eyedropper
                                    isEyedropperActive = true
                                }
                            )
                        }
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.8))
                        )
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Bottom control bar
                    bottomControlBar
                        .padding(.bottom, 20)
                        .opacity(isEyedropperActive ? 0 : 1) // Hide bottom controls
                }
                
                // Vertical size slider on right edge
                verticalSizeSlider(screenHeight: geometry.size.height)
                    .position(x: geometry.size.width - 40, y: geometry.size.height / 2)
                    .opacity(isEyedropperActive ? 0 : 1) // Hide slider
                
                // Eyedropper overlay
                if isEyedropperActive {
                    EyedropperOverlayView(
                        canvasSnapshot: canvasSnapshot,
                        selectedColor: colorPickerMode == .textColor ? $textColor : $backgroundColor,
                        onColorPicked: { color in
                            if colorPickerMode == .textColor {
                                textColor = color
                            } else {
                                backgroundColor = color
                            }
                            isEyedropperActive = false
                        },
                        onCancel: {
                            isEyedropperActive = false
                        }
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showColorPalette)
            .animation(.easeInOut(duration: 0.2), value: isEyedropperActive)
        }
        .sheet(isPresented: $showFontPicker) {
            FontPickerView(selectedFontFamily: $selectedFontFamily, selectedFontWeight: $selectedFontWeight)
        }
        .onAppear {
            setupInitialState()
            // Auto-focus to show keyboard
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
    }
    
    // MARK: - Bottom Control Bar
    
    private var bottomControlBar: some View {
        HStack(spacing: 20) {
            // Font button
            VStack(spacing: 4) {
                Button {
                    isTextFieldFocused = false
                    showFontPicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Text("Aa")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Text(selectedFontFamily.prefix(6))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            
            // Text Color button
            VStack(spacing: 4) {
                Button {
                    isTextFieldFocused = false
                    colorPickerMode = .textColor
                    withAnimation {
                        showColorPalette = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(showColorPalette && colorPickerMode == .textColor ? Color.blue : Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Circle()
                            .fill(textColor)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
                Text(NSLocalizedString("顏色", comment: "Color"))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Alignment button
            VStack(spacing: 4) {
                Button {
                    cycleAlignment()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Image(systemName: alignmentIcon)
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }
                Text(NSLocalizedString("對齊", comment: "Alignment"))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Background type button (cycle through none/solid/transparent)
            VStack(spacing: 4) {
                Button {
                    cycleBackground()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Image(systemName: backgroundIcon)
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }
                Text(backgroundLabel)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Background Color button (only show when background is not none)
            if backgroundType != .none {
                VStack(spacing: 4) {
                    Button {
                        isTextFieldFocused = false
                        colorPickerMode = .backgroundColor
                        withAnimation {
                            showColorPalette = true
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(showColorPalette && colorPickerMode == .backgroundColor ? Color.blue : Color.white.opacity(0.2))
                                .frame(width: 50, height: 50)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(backgroundColor)
                                .frame(width: 36, height: 28)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                    Text(NSLocalizedString("背景色", comment: "Background color"))
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.8))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black.opacity(0.6))
        )
        .animation(.easeInOut(duration: 0.2), value: backgroundType)
    }
    
    // MARK: - Vertical Size Slider
    
    private func verticalSizeSlider(screenHeight: CGFloat) -> some View {
        VStack(spacing: 8) {
            Text("\(Int(fontSize))")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(6)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.6))
                )
            
            Slider(value: $fontSize, in: 12...72, step: 1)
                .rotationEffect(.degrees(-90))
                .frame(width: min(screenHeight * 0.4, 250), height: 44)
                .accentColor(.white)
        }
    }
    
    // MARK: - Helper Properties
    
    private var alignmentIcon: String {
        switch alignment {
        case .leading: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .trailing: return "text.alignright"
        }
    }
    
    private var backgroundIcon: String {
        switch backgroundType {
        case .none: return "square.dashed"
        case .solid: return "square.fill"
        case .semiTransparent: return "square.lefthalf.filled"
        }
    }
    
    private var backgroundLabel: String {
        switch backgroundType {
        case .none: return NSLocalizedString("無", comment: "None")
        case .solid: return NSLocalizedString("實心", comment: "Solid")
        case .semiTransparent: return NSLocalizedString("透明", comment: "Semi-transparent short")
        }
    }
    
    // MARK: - Helper Functions
    
    private func cycleAlignment() {
        switch alignment {
        case .leading:
            alignment = .center
        case .center:
            alignment = .trailing
        case .trailing:
            alignment = .leading
        }
    }
    
    private func cycleBackground() {
        switch backgroundType {
        case .none:
            // When enabling background, set to contrast color of text
            backgroundColor = contrastColor(for: textColor)
            backgroundType = .solid
        case .solid:
            backgroundType = .semiTransparent
        case .semiTransparent:
            backgroundType = .none
        }
    }
    
    /// Calculate a contrasting background color based on text color
    /// Light colors get dark backgrounds, dark colors get light backgrounds
    private func contrastColor(for color: Color) -> Color {
        // Convert Color to UIColor to access RGB components
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate relative luminance using sRGB formula
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        if luminance > 0.5 {
            // Light color -> dark background (invert and darken)
            return Color(
                red: Double(red * 0.2),
                green: Double(green * 0.2),
                blue: Double(blue * 0.2)
            )
        } else {
            // Dark color -> light background (invert and lighten)
            return Color(
                red: Double(1.0 - (1.0 - red) * 0.3),
                green: Double(1.0 - (1.0 - green) * 0.3),
                blue: Double(1.0 - (1.0 - blue) * 0.3)
            )
        }
    }
    
    private func fontForCurrentSelection(size: CGFloat) -> Font {
        guard let family = FontFamily.fontByName(selectedFontFamily),
              let weight = family.weightByName(selectedFontWeight) else {
            return .system(size: size)
        }

        if family.isSystemFont && family.displayName == "SF Pro" {
            return .system(size: size, weight: weight.weight)
        }

        return .custom(weight.postScriptName, size: size)
    }
    
    private func setupInitialState() {
        if let element = textElement {
            text = element.text
            selectedFontFamily = element.fontFamily
            selectedFontWeight = element.fontWeight
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
            // Default to white color for new text (visible on dark overlay)
            textColor = .white
        }
    }
    
    private func saveAndDismiss() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If text is empty and editing existing element, delete it
        if trimmedText.isEmpty {
            if textElement != nil {
                onDelete?()
            } else {
                onCancel?()
            }
            return
        }
        
        var element = textElement ?? TextElement(text: trimmedText)

        element.text = trimmedText
        element.fontFamily = selectedFontFamily
        element.fontWeight = selectedFontWeight
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
    }
}

// MARK: - Direct Color Picker (shows system color picker immediately)

struct DirectColorPickerView: UIViewControllerRepresentable {
    @Binding var selectedColor: Color
    var onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        picker.selectedColor = UIColor(selectedColor)
        picker.supportsAlpha = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
        uiViewController.selectedColor = UIColor(selectedColor)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: DirectColorPickerView
        
        init(_ parent: DirectColorPickerView) {
            self.parent = parent
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            parent.selectedColor = Color(viewController.selectedColor)
        }
        
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            parent.onDismiss()
        }
    }
}
