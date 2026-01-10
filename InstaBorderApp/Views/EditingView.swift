import SwiftUI

struct EditingView: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    @State private var showingSaveSuccess = false
    @State private var saveMessage = ""
    @State private var currentRatio: CGFloat = BorderConfiguration.ratio4x5
    @State private var currentColor: Color = .white
    @State private var imageScale: CGFloat = 0.8
    @State private var showRatioSheet = false
    @State private var showColorSheet = false
    @State private var isSaving = false
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
            .background(Color.black)
            
            // Photos Grid
            ScrollView {
                let cols = viewModel.processedThumbnails.count == 1 
                    ? [GridItem(.flexible())]
                    : [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)]
                
                LazyVGrid(columns: cols, spacing: 1) {
                    ForEach(0..<viewModel.processedThumbnails.count, id: \.self) { i in
                        Image(uiImage: viewModel.processedThumbnails[i])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .overlay(Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5))
                    }
                }
            }
            .background(Color.black)
            
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
                
                HStack(spacing: 50) {
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
                }
            }
            .padding(.vertical, 16)
            .background(Color.black)
        }
        .background(Color.black)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $showRatioSheet) {
            RatioSheet(currentRatio: $currentRatio) { applyChanges() }
                .presentationDetents([.height(180)])
        }
        .sheet(isPresented: $showColorSheet) {
            ColorSheet(currentColor: $currentColor) { applyChanges() }
                .presentationDetents([.height(220)])
        }
        .overlay(
            Group {
                if isSaving || viewModel.isProcessing {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView().tint(.white).scaleEffect(1.3)
                        Text(isSaving ? NSLocalizedString("status.saving", comment: "") : NSLocalizedString("status.processing", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.white)
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
