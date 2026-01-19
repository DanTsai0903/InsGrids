import SwiftUI

struct EditingView: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    @StateObject private var presetManager = PresetManager()
    @State private var showingSaveSuccess = false
    @State private var saveMessage = ""
    @State private var currentRatio: CGFloat = BorderConfiguration.ratio4x5
    @State private var currentColor: Color = .white
    @State private var imageScale: CGFloat = 0.8
    @State private var showRatioSheet = false
    @State private var showColorSheet = false
    @State private var showPresetsSheet = false
    @State private var isSaving = false
    
    // Photo Editor State
    @State private var showPhotoEditor = false
    @State private var selectedImageIndex: Int = 0
    @State private var editingAdjustments = PhotoAdjustments()
    
    @Environment(\.dismiss) var dismiss
    
    private var ratioLabel: String {
        if abs(currentRatio - BorderConfiguration.ratio1x1) < 0.01 { return "1:1" }
        if abs(currentRatio - BorderConfiguration.ratio4x5) < 0.01 { return "4:5" }
        if abs(currentRatio - BorderConfiguration.ratio16x9) < 0.01 { return "16:9" }
        if abs(currentRatio - BorderConfiguration.ratio9x16) < 0.01 { return "9:16" }
        return String(format: "%.2f", currentRatio)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                }
                Spacer()
                
                // Title
                Text(NSLocalizedString("app.title", comment: ""))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                Button(action: saveImages) {
                    Text(NSLocalizedString("button.save", comment: ""))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(18)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 8)
            .background(.bar)
            
            // Photos Grid
            ScrollView {
                let cols = viewModel.processedThumbnails.count == 1 
                    ? [GridItem(.flexible())]
                    : [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)]
                
                LazyVGrid(columns: cols, spacing: 1) {
                    ForEach(0..<viewModel.processedThumbnails.count, id: \.self) { i in
                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: viewModel.processedThumbnails[i])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .overlay(Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5))
                            
                            // Edit Indicator
                            Button {
                                openEditor(at: i)
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .padding(8)
                        }
                        .onTapGesture {
                            openEditor(at: i)
                        }
                    }
                }
            }
            .background(ThemeColors.background)

            // Bottom Controls
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "photo.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Slider(value: $imageScale, in: 0.3...1.0, step: 0.01)
                        .tint(.white)
                        .onChange(of: imageScale) { _, _ in applyChanges() }
                    Text("\(Int(imageScale * 100))%")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 36)
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 40) {
                    Button(action: { showRatioSheet = true }) {
                        VStack(spacing: 6) {
                            Image(systemName: "aspectratio")
                                .font(.system(size: 22))
                            Text(ratioLabel)
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                    }
                    
                    Button(action: { showColorSheet = true }) {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(currentColor)
                                .frame(width: 24, height: 24)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            Text(NSLocalizedString("label.border", comment: ""))
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                    }
                    
                    Button(action: { showPresetsSheet = true }) {
                        VStack(spacing: 6) {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 22))
                            Text(NSLocalizedString("presets.title", comment: ""))
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .padding(.vertical, 16)
            .background(.bar)
        }
        .background(ThemeColors.background)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $showRatioSheet) {
            RatioSheet(currentRatio: $currentRatio) { applyChanges() }
                .presentationDetents([.height(180)])
                .presentationBackground(.regularMaterial)
        }
        .sheet(isPresented: $showColorSheet) {
            ColorSheet(currentColor: $currentColor) { applyChanges() }
                .presentationDetents([.height(220)])
                .presentationBackground(.regularMaterial)
        }
        .sheet(isPresented: $showPresetsSheet) {
            PresetsSheet(
                presetManager: presetManager,
                currentConfig: Binding(
                    get: { BorderConfiguration(borderColor: currentColor, aspectRatio: currentRatio, imageScale: imageScale) },
                    set: { _ in }
                ),
                onApply: { config in
                    self.currentRatio = config.aspectRatio
                    self.currentColor = config.borderColor
                    self.imageScale = config.imageScale
                    applyChanges()
                }
            )
            .presentationDetents([.medium, .large])
            .presentationBackground(.regularMaterial)
        }
        .fullScreenCover(isPresented: $showPhotoEditor) {
            if let original = viewModel.getOriginalImage(at: selectedImageIndex) {
                PhotoEditorView(
                    originalImage: original,
                    initialAdjustments: editingAdjustments,
                    onSave: { finalAdjustments in
                        viewModel.updateAdjustment(at: selectedImageIndex, adjustment: finalAdjustments)
                        showPhotoEditor = false
                    },
                    onCancel: {
                        showPhotoEditor = false
                    }
                )
            } else {
                Text("Error loading image")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .onTapGesture { showPhotoEditor = false }
            }
        }
        .overlay(
            Group {
                if isSaving || viewModel.isProcessing {
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView().tint(.white).scaleEffect(1.3)
                            Text(isSaving ? NSLocalizedString("status.saving", comment: "") : NSLocalizedString("status.processing", comment: ""))
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        )
        .alert(NSLocalizedString("alert.complete", comment: ""), isPresented: $showingSaveSuccess) {
            Button(NSLocalizedString("button.ok", comment: "")) {}
        } message: {
            Text(saveMessage)
        }
        .onAppear { applyChanges() }
        .onDisappear { viewModel.clearAll() }
    }
    
    private func applyChanges() {
        viewModel.updateConfiguration(BorderConfiguration(borderColor: currentColor, aspectRatio: currentRatio, imageScale: imageScale))
    }
    
    private func saveImages() {
        isSaving = true
        viewModel.processAndSaveAll { success, count in
            isSaving = false
            saveMessage = success 
                ? String(format: NSLocalizedString("alert.savedPhotos", comment: ""), count)
                : NSLocalizedString("alert.saveFailed", comment: "")
            showingSaveSuccess = true
        }
    }
    
    private func openEditor(at index: Int) {
        selectedImageIndex = index
        // Clone existing adjustments if within range, otherwise default
        if index < viewModel.adjustments.count {
            editingAdjustments = viewModel.adjustments[index]
        } else {
            editingAdjustments = PhotoAdjustments()
        }
        showPhotoEditor = true
    }
}

// MARK: - Sheets
struct RatioSheet: View {
    @Binding var currentRatio: CGFloat
    var onSelect: () -> Void
    @Environment(\.dismiss) var dismiss
    let ratios: [(String, CGFloat)] = [("1:1", 1.0), ("4:5", 0.8), ("16:9", 16.0/9.0), ("9:16", 9.0/16.0)]
    
    var body: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("label.selectRatio", comment: "")).font(.headline).padding(.top)
            HStack(spacing: 12) {
                ForEach(ratios, id: \.0) { r in
                    Button { currentRatio = r.1; onSelect(); dismiss() } label: {
                        Text(r.0).font(.subheadline.bold())
                            .frame(width: 60, height: 40)
                            .background(abs(currentRatio - r.1) < 0.01 ? Color.blue : Color(UIColor.systemGray5))
                            .foregroundColor(abs(currentRatio - r.1) < 0.01 ? .white : .primary)
                            .cornerRadius(10)
                    }
                }
            }
            Spacer()
        }
    }
}

struct ColorSheet: View {
    @Binding var currentColor: Color
    var onSelect: () -> Void
    @Environment(\.dismiss) var dismiss
    let presets: [Color] = [.white, .black, Color(white: 0.95), Color(white: 0.15)]
    
    var body: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("label.borderColor", comment: "")).font(.headline).padding(.top)
            HStack(spacing: 16) {
                ForEach(presets, id: \.self) { c in
                    Button { currentColor = c; onSelect(); dismiss() } label: {
                        Circle().fill(c).frame(width: 40, height: 40)
                            .overlay(Circle().stroke(Color.gray.opacity(0.3)))
                            .overlay(Circle().stroke(Color.blue, lineWidth: currentColor == c ? 2 : 0))
                    }
                }
                ColorPicker("", selection: $currentColor).labelsHidden()
                    .onChange(of: currentColor) { _, _ in onSelect() }
            }
            Button(NSLocalizedString("button.done", comment: "")) { dismiss() }
                .font(.headline).foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 44)
                .background(Color.blue).cornerRadius(10)
                .padding(.horizontal, 20)
            Spacer()
        }
    }
}
