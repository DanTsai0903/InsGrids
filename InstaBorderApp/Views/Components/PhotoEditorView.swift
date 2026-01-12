import SwiftUI
import Combine

/// Full-screen photo editor with adjustments and filters
struct PhotoEditorView: View {
    let originalImage: UIImage
    let onSave: (PhotoAdjustments) -> Void
    let onCancel: () -> Void
    
    @State private var adjustments: PhotoAdjustments
    @State private var originalPreviewImage: UIImage?  // Clean original for rendering base
    @State private var displayedPreviewImage: UIImage? // Rendered preview with adjustments
    @State private var selectedTab: EditorTab = .adjust
    @State private var isProcessing = false
    @State private var showingOriginal = false  // Toggle to show original vs edited
    @State private var showFilterIntensitySlider = false // Toggle for filter strength slider
    
    private let engine = PhotoEditorEngine()
    
    // Debounce publisher for throttling preview updates
    @State private var adjustmentsPublisher = PassthroughSubject<PhotoAdjustments, Never>()
    
    /// Small thumbnail for filter previews
    @State private var filterThumbnail: UIImage?
    
    enum EditorTab {
        case adjust
        case filter
    }
    
    init(originalImage: UIImage, initialAdjustments: PhotoAdjustments = PhotoAdjustments(), onSave: @escaping (PhotoAdjustments) -> Void, onCancel: @escaping () -> Void) {
        self.originalImage = originalImage
        self.onSave = onSave
        self.onCancel = onCancel
        self._adjustments = State(initialValue: initialAdjustments)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerBar
            
            // Image Preview
            imagePreview
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Controls
            VStack(spacing: 0) {
                // Tab Selector
                tabSelector
                
                // Content based on selected tab
                if selectedTab == .adjust {
                    adjustmentsPanel
                } else {
                    filtersPanel
                }
            }
            .background(Color.black.opacity(0.95))
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            // Generate downsampled preview image (400px for performance)
            let size = CGSize(width: 400, height: 400 * (originalImage.size.height / originalImage.size.width))
            let renderer = UIGraphicsImageRenderer(size: size)
            let downsampledPreview = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: size))
            }
            
            // Generate even smaller thumbnail for filter previews
            let thumbSize = CGSize(width: 80, height: 80 * (originalImage.size.height / originalImage.size.width))
            let thumbRenderer = UIGraphicsImageRenderer(size: thumbSize)
            filterThumbnail = thumbRenderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: thumbSize))
            }
            
            // Keep clean original for rendering base
            originalPreviewImage = downsampledPreview
            displayedPreviewImage = downsampledPreview
            updatePreview()
        }
        .onChange(of: adjustments) { _, newValue in
            // Send to debounced publisher instead of direct update
            adjustmentsPublisher.send(newValue)
        }
        .onReceive(
            adjustmentsPublisher
                .debounce(for: .milliseconds(20), scheduler: DispatchQueue.main)
        ) { _ in
            updatePreview()
        }
    }
    
    // MARK: - Header Bar
    private var headerBar: some View {
        HStack(spacing: 12) {
            Button(action: onCancel) {
                Text(NSLocalizedString("button.cancel", comment: "Cancel"))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Reset button
            Button {
                withAnimation {
                    adjustments.reset()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundColor(adjustments.hasAdjustments ? .white : .gray)
            }
            .disabled(!adjustments.hasAdjustments)
            
            // Title
            Text(NSLocalizedString("title.edit", value: "Edit", comment: "Edit Title"))
                .font(.headline)
                .foregroundColor(.white)
            
            // Compare (show original) button
            Button {
                showingOriginal.toggle()
            } label: {
                Image(systemName: showingOriginal ? "eye.fill" : "eye")
                    .foregroundColor(showingOriginal ? .blue : .white)
            }
            
            Spacer()
            
            Button {
                onSave(adjustments)
            } label: {
                Text(NSLocalizedString("button.done", comment: "Done"))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.black)
    }
    
    // MARK: - Image Preview
    private var imagePreview: some View {
        GeometryReader { geometry in
            // Choose image based on compare toggle
            let imageToShow = showingOriginal ? originalPreviewImage : displayedPreviewImage
            
            if let preview = imageToShow {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    // Visual indicator for "Original" mode
                    .overlay(
                        showingOriginal ? 
                            Text("ORIGINAL")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(4)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            : nil
                    )
            } else {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: NSLocalizedString("editor.adjust", value: "Adjust", comment: "Adjust tab"), tab: .adjust)
            tabButton(title: NSLocalizedString("editor.filter", value: "Filter", comment: "Filter tab"), tab: .filter)
        }
        .padding(.top, 8)
    }
    
    private func tabButton(title: String, tab: EditorTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(selectedTab == tab ? .semibold : .regular)
                    .foregroundColor(selectedTab == tab ? .white : .gray)
                
                Rectangle()
                    .fill(selectedTab == tab ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Adjustments Panel
    // MARK: - Adjustments Panel
    private var adjustmentsPanel: some View {
        ScrollView {
            VStack(spacing: 16) {
                // LIGHT (亮) Group like Lightroom
                Group {
                    adjustmentSlider(name: NSLocalizedString("adjust.exposure", value: "Exposure", comment: ""), 
                                   value: $adjustments.exposure, range: -2...2, defaultValue: 0)
                    adjustmentSlider(name: NSLocalizedString("adjust.contrast", value: "Contrast", comment: ""), 
                                   value: $adjustments.contrast, range: 0.5...1.5, defaultValue: 1)
                    adjustmentSlider(name: NSLocalizedString("adjust.highlights", value: "Highlights", comment: ""), 
                                   value: $adjustments.highlights, range: -1...1, defaultValue: 0)
                    adjustmentSlider(name: NSLocalizedString("adjust.shadows", value: "Shadows", comment: ""), 
                                   value: $adjustments.shadows, range: -1...1, defaultValue: 0)
                    adjustmentSlider(name: NSLocalizedString("adjust.whites", value: "Whites", comment: ""), 
                                   value: $adjustments.whites, range: -1...1, defaultValue: 0)
                    adjustmentSlider(name: NSLocalizedString("adjust.blacks", value: "Blacks", comment: ""), 
                                   value: $adjustments.blacks, range: -1...1, defaultValue: 0)
                }
                
                Divider().background(Color.gray.opacity(0.3))
                
                // COLOR / DETAIL Group
                Group {
                    adjustmentSlider(name: NSLocalizedString("adjust.saturation", value: "Saturation", comment: ""), 
                                   value: $adjustments.saturation, range: 0...2, defaultValue: 1)
                    adjustmentSlider(name: NSLocalizedString("adjust.warmth", value: "Warmth", comment: ""), 
                                   value: $adjustments.warmth, range: -1...1, defaultValue: 0)
                    adjustmentSlider(name: NSLocalizedString("adjust.vignette", value: "Vignette", comment: ""), 
                                   value: $adjustments.vignette, range: 0...2, defaultValue: 0)
                    adjustmentSlider(name: NSLocalizedString("adjust.sharpness", value: "Sharpness", comment: ""), 
                                   value: $adjustments.sharpness, range: 0...1, defaultValue: 0)
                }
            }
            .padding()
        }
        .frame(height: 220)
    }
    
    private func adjustmentSlider(name: String, value: Binding<Double>, range: ClosedRange<Double>, defaultValue: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(String(format: "%.2f", value.wrappedValue))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 50, alignment: .trailing)
            }
            
            HStack {
                Slider(value: value, in: range)
                    .tint(.blue)
                
                // Reset button
                Button {
                    value.wrappedValue = defaultValue
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Filters Panel
    private var filtersPanel: some View {
        VStack(spacing: 12) {
            // Intensity Slider (appears when tapping selected filter again)
            if showFilterIntensitySlider && adjustments.filterName != nil {
                VStack(spacing: 4) {
                    HStack {
                        Text(NSLocalizedString("adjust.strength", value: "Strength", comment: ""))
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.0f%%", adjustments.filterIntensity * 100))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Slider(value: $adjustments.filterIntensity, in: 0...1)
                        .tint(.blue)
                        .padding(.horizontal)
                }
                .transition(.scale.combined(with: .opacity))
                .padding(.top, 8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // "None" option
                    filterButton(name: NSLocalizedString("filter.none", comment: "None filter"), filterName: nil)
                    
                    // All available filters
                    ForEach(PhotoAdjustments.availableFilters, id: \.name) { filter in
                        filterButton(name: NSLocalizedString(filter.localizationKey, comment: ""), filterName: filter.name)
                    }
                }
                .padding()
            }
        }
        .frame(minHeight: 120) // Allow growth for slider
    }
    
    private func filterButton(name: String, filterName: String?) -> some View {
        let isSelected = adjustments.filterName == filterName
        let displayImage: UIImage? = {
            guard let thumb = filterThumbnail else { return nil }
            if let fn = filterName {
                return engine.generateFilterThumbnail(image: thumb, filterName: fn)
            }
            return thumb
        }()
        
        return Button {
            if adjustments.filterName == filterName {
                // Toggle slider if filter is already selected and not nil
                if filterName != nil {
                    withAnimation {
                        showFilterIntensitySlider.toggle()
                    }
                }
            } else {
                // Select new filter
                adjustments.filterName = filterName
                adjustments.filterIntensity = 1.0 // Reset to full strength
                withAnimation {
                    showFilterIntensitySlider = false // Auto-hide
                }
            }
        } label: {
            VStack(spacing: 4) {
                // Thumbnail
                if let img = displayImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                }
                
                Text(name)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .white)
            }
        }
    }
    
    // MARK: - Preview Update
    private func updatePreview() {
        // Always render from the CLEAN original to prevent stacking
        guard let baseImage = originalPreviewImage else { return }
        
        // Render on background thread (already debounced by Combine)
        DispatchQueue.global(qos: .userInitiated).async {
            let result = engine.render(image: baseImage, adjustments: adjustments)
            DispatchQueue.main.async {
                displayedPreviewImage = result
            }
        }
    }
}
