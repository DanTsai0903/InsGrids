import SwiftUI
import PhotosUI

/// Main view for freeform grid editing
struct GridEditingView: View {
    @StateObject private var viewModel = GridViewModel()
    @Environment(\.dismiss) var dismiss
    
    // UI State
    @State private var showDimensionPicker = false
    @State private var showImagePicker = false
    @State private var showColorPicker = false
    @State private var showExportSuccess = false
    @State private var showDeleteConfirm = false
    @State private var exportMessage = ""
    
    // Grid dimensions for picker
    @State private var pickerRows: Int = 2
    @State private var pickerColumns: Int = 2
    
    // Photo picker
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    // Canvas size for export
    @State private var canvasSize: CGSize = .zero
    
    // Canvas zoom scale
    @State private var canvasScale: CGFloat = 1.0
    
    // Delete button state (shared with canvas)
    @State private var pendingDeleteImageId: UUID? = nil
    
    // Cropping
    @State private var cropImageId: UUID? = nil
    @State private var showCropSheet = false

    
    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar
            topToolbar
            
            // Freeform Canvas
            GeometryReader { geometry in
                let cellWidth = geometry.size.width / CGFloat(viewModel.columns)
                let cellHeight = cellWidth / (4.0 / 5.0)
                let gridHeight = cellHeight * CGFloat(viewModel.rows)
                
                FreeformCanvasView(
                    images: $viewModel.canvasImages,
                    canvasScale: $canvasScale,
                    pendingDeleteImageId: $pendingDeleteImageId,
                    gridRows: viewModel.rows,
                    gridColumns: viewModel.columns,
                    backgroundColor: viewModel.backgroundColor,
                    onBringToFront: { id in
                        viewModel.bringToFront(id)
                    },
                    onDeleteImage: { id in
                        viewModel.removeImage(id)
                    },
                    onCropImage: { id in
                        pendingDeleteImageId = nil
                        cropImageId = id
                        // Add a tiny delay to ensure everything is settled before presenting sheet
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showCropSheet = true
                        }
                    },
                    onImageManipulationStart: {
                        viewModel.saveImageSnapshot()
                    }
                )
                .frame(width: geometry.size.width, height: max(gridHeight, geometry.size.height))
                .background(Color.black)
                .onAppear {
                    canvasSize = CGSize(width: geometry.size.width, height: gridHeight)
                }
                .onChange(of: geometry.size) { _, newSize in
                    let newCellWidth = newSize.width / CGFloat(viewModel.columns)
                    let newCellHeight = newCellWidth / (4.0 / 5.0)
                    canvasSize = CGSize(width: newSize.width, height: newCellHeight * CGFloat(viewModel.rows))
                }
            }
        }
        .background(Color.black)
        .contentShape(Rectangle())
        .onTapGesture {
            pendingDeleteImageId = nil
        }
        .navigationBarHidden(true)
        .onAppear {
            pickerRows = viewModel.rows
            pickerColumns = viewModel.columns
            viewModel.startAutoSave()
        }
        .onDisappear {
            viewModel.stopAutoSave()
        }
        // Dimension picker sheet
        .sheet(isPresented: $showDimensionPicker) {
            GridDimensionPicker(
                rows: $pickerRows,
                columns: $pickerColumns
            ) {
                viewModel.updateGridSize(rows: pickerRows, columns: pickerColumns)
            }
            .presentationDetents([.medium])
        }
        // Image picker
        .photosPicker(
            isPresented: $showImagePicker,
            selection: $selectedPhotos,
            maxSelectionCount: 20,
            matching: .images
        )
        .onChange(of: selectedPhotos) { _, newItems in
            loadImages(from: newItems)
        }
        // Image Crop Sheet
        .fullScreenCover(isPresented: $showCropSheet) {
            cropSheetContent
        }
        // Color picker sheet
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(
                currentColor: viewModel.backgroundColor,
                onSelect: { color in
                    viewModel.setBackgroundColor(color)
                }
            )
            .presentationDetents([.medium])
        }

        // Restore session alert
        .alert(
            NSLocalizedString("grid.restore.title", comment: "Restore Previous Grid?"),
            isPresented: $viewModel.showRestoreAlert
        ) {
            Button(NSLocalizedString("grid.restore.yes", comment: "Restore")) {
                viewModel.restoreSession()
            }
            Button(NSLocalizedString("button.cancel", comment: "Cancel"), role: .cancel) {
                viewModel.discardSession()
            }
        } message: {
            Text(NSLocalizedString("grid.restore.message", comment: "A previous editing session was found."))
        }
        // Export success alert
        .alert(
            NSLocalizedString("alert.success", comment: "Success"),
            isPresented: $showExportSuccess
        ) {
            Button(NSLocalizedString("button.ok", comment: "OK")) {}
        } message: {
            Text(exportMessage)
        }
        // Processing overlay
        .overlay {
            if viewModel.isProcessing {
                Color.black.opacity(0.7).ignoresSafeArea()
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text(NSLocalizedString("grid.exporting", comment: "Exporting tiles..."))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Top Toolbar
    
    private var topToolbar: some View {
        HStack(spacing: 12) {
            // Back button
            Button {
                pendingDeleteImageId = nil
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }
            
            // Add photos button
            Button {
                pendingDeleteImageId = nil
                showImagePicker = true
            } label: {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }
            
            // Grid size button (replaces grid icon)
            Button {
                pendingDeleteImageId = nil
                showDimensionPicker = true
            } label: {
                Text("\(viewModel.rows)×\(viewModel.columns)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
            }
            
            // Background color button
            Button {
                pendingDeleteImageId = nil
                showColorPicker = true
            } label: {
                Circle()
                    .fill(viewModel.backgroundColor)
                    .frame(width: 22, height: 22)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            Spacer()
            
            // Undo button
            Button {
                pendingDeleteImageId = nil
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward.circle")
                    .font(.system(size: 20))
                    .foregroundColor(viewModel.canUndo ? .white : .gray)
            }
            .disabled(!viewModel.canUndo)
            
            // Export button
            Button {
                pendingDeleteImageId = nil
                exportTiles()
            } label: {
                Text(NSLocalizedString("grid.export", comment: "Export"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(14)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .background(Color.black)
    }
    
    @ViewBuilder
    private var cropSheetContent: some View {
        if let id = cropImageId,
           let canvasImage = viewModel.canvasImages.first(where: { $0.id == id }) {
            // Try to load high-res original for editing, fallback to proxy if needed
            let imageToEdit = viewModel.loadOriginal(id: id) ?? canvasImage.image
            
            ImageCropView(
                originalImage: imageToEdit,
                onCrop: { croppedImage in
                    viewModel.updateImage(id, newImage: croppedImage)
                    cropImageId = nil
                    showCropSheet = false
                },
                onCancel: {
                    cropImageId = nil
                    showCropSheet = false
                }
            )
        } else {
            // Fallback if image not found
            Color.black.onAppear { showCropSheet = false }
        }
    }
    
    // MARK: - Actions
    
    private func loadImages(from items: [PhotosPickerItem]) {
        Task {
            var loadedData: [Data] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    loadedData.append(data)
                }
            }
            await MainActor.run {
                viewModel.addImages(loadedData, canvasSize: canvasSize)
                selectedPhotos.removeAll()
            }
        }
    }
    
    private func exportTiles() {
        viewModel.exportTiles(canvasSize: canvasSize) { success, count in
            if success {
                exportMessage = String(format: NSLocalizedString("grid.export.success", comment: "Successfully saved %d grid tiles to Photos"), count)
            } else {
                exportMessage = NSLocalizedString("grid.export.failed", comment: "Failed to export some tiles")
            }
            showExportSuccess = true
        }
    }
}

// MARK: - Color Picker Sheet

struct ColorPickerSheet: View {
    let currentColor: Color
    var onSelect: (Color) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedColor: Color
    
    let presetColors: [Color] = [.white, .black, Color(white: 0.95), Color(white: 0.15), .red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    init(currentColor: Color, onSelect: @escaping (Color) -> Void) {
        self.currentColor = currentColor
        self.onSelect = onSelect
        self._selectedColor = State(initialValue: currentColor)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("grid.background.title", comment: "Background Color"))
                .font(.headline)
                .padding(.top, 20)
            
            // Preset colors
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(presetColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.blue : Color.gray.opacity(0.3), lineWidth: selectedColor == color ? 3 : 1)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding(.horizontal)
            
            // Color picker
            ColorPicker(NSLocalizedString("grid.background.custom", comment: "Custom Color"), selection: $selectedColor)
                .padding(.horizontal)
            
            // Apply button
            Button {
                onSelect(selectedColor)
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
            
            Spacer()
        }
    }
}

// MARK: - Image Crop View
struct ImageCropView: View {
    let originalImage: UIImage
    let onCrop: (UIImage) -> Void
    let onCancel: () -> Void
    
    @State private var cropRect: CGRect = .zero
    @State private var imageRect: CGRect = .zero
    @State private var viewSize: CGSize = .zero
    @State private var selectedRatio: CGFloat? = nil
    @State private var displayImage: UIImage? = nil // Downsampled for display
    
    private let touchTarget: CGFloat = 30
    private let minCropSize: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onCancel) {
                    Text(NSLocalizedString("button.cancel", comment: "Cancel"))
                        .foregroundColor(.white)
                }
                Spacer()
                Text(NSLocalizedString("title.crop", value: "Crop Image", comment: "Crop Image Title"))
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    performCrop()
                } label: {
                    Text(NSLocalizedString("button.done", comment: "Done"))
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.black)
            
            Spacer()
            
            // Editor Area
            // Editor Area
            GeometryReader { geometry in
                ZStack {
                    if viewSize.width > 0 && viewSize.height > 0 {
                        ZStack {
                            // 1. The Image (Strictly use ONLY displayImage to prevent OOM)
                            if let displayImg = displayImage {
                                Image(uiImage: displayImg)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: viewSize.width, height: viewSize.height)
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                
                                // 2. Dimmed Overlay & Handles (Only show when image is loaded)

                            if cropRect.width > 0 && cropRect.height > 0 {
                                // Dimmed Overlay with Hole
                                Rectangle()
                                    .fill(Color.black.opacity(0.5))
                                    .overlay(
                                        Rectangle()
                                            .frame(width: cropRect.width, height: cropRect.height)
                                            .position(x: cropRect.midX, y: cropRect.midY)
                                            .blendMode(.destinationOut)
                                    )
                                    .compositingGroup()
                                    .allowsHitTesting(false)
                                
                                // Crop Handles & Border
                                ZStack {
                                    // Border
                                    Rectangle()
                                        .stroke(Color.white, lineWidth: 1)
                                        .frame(width: cropRect.width, height: cropRect.height)
                                        .position(x: cropRect.midX, y: cropRect.midY)
                                    
                                    // Grid lines (3x3)
                                    VStack(spacing: 0) {
                                        Spacer()
                                        Divider().background(Color.white.opacity(0.5))
                                        Spacer()
                                        Divider().background(Color.white.opacity(0.5))
                                        Spacer()
                                    }
                                    .frame(width: cropRect.width, height: cropRect.height)
                                    .position(x: cropRect.midX, y: cropRect.midY)
                                    
                                    HStack(spacing: 0) {
                                        Spacer()
                                        Rectangle().fill(Color.white.opacity(0.5)).frame(width: 1)
                                        Spacer()
                                        Rectangle().fill(Color.white.opacity(0.5)).frame(width: 1)
                                        Spacer()
                                    }
                                    .frame(width: cropRect.width, height: cropRect.height)
                                    .position(x: cropRect.midX, y: cropRect.midY)
                                    
                                    // Corner Handles
                                    handle(at: .topLeft)
                                    handle(at: .topRight)
                                    handle(at: .bottomLeft)
                                    handle(at: .bottomRight)
                                    
                                    // Side Handles
                                    sideHandle(for: .top)
                                    sideHandle(for: .bottom)
                                    sideHandle(for: .left)
                                    sideHandle(for: .right)
                                }
                                // Allow dragging anywhere on screen to move crop rect? 
                                // Or just specific area? User said "move the box freely".
                                // Usually this means dragging inside the box.
                                .contentShape(Rectangle()) 
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            moveCropRect(value.translation)
                                        }
                                        .onEnded { _ in
                                            dragStartRect = nil
                                        }
                                )
                            }
                        } else {
                            // Loading state while downsampling
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                                .frame(width: viewSize.width, height: viewSize.height)
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }

                    }
                } else {
                        // Fallback while calculating layout
                        Color.black
                    }
                }
                .onAppear {
                    self.viewSize = geometry.size
                    self.calculateImageRect(containerSize: geometry.size)
                    self.cropRect = self.imageRect
                    
                    // Generate downsampled image for display to save memory
                    if displayImage == nil {
                        DispatchQueue.global(qos: .userInitiated).async {
                            let downsampled = self.downsample(image: self.originalImage, to: 1000)
                            DispatchQueue.main.async {
                                self.displayImage = downsampled
                            }
                        }
                    }
                }
                .onChange(of: geometry.size) { _, newSize in
                    self.viewSize = newSize
                    self.calculateImageRect(containerSize: newSize)
                }
            }
            .background(Color.black)
            
            // Bottom Toolbar (Ratios)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ratioButton(label: "Free", ratio: nil)
                    ratioButton(label: "Original", ratio: originalImage.size.width / originalImage.size.height)
                    ratioButton(label: "1:1", ratio: 1)
                    ratioButton(label: "4:5", ratio: 4/5) // Vertical
                    ratioButton(label: "5:4", ratio: 5/4) // Horizontal
                    ratioButton(label: "16:9", ratio: 16/9)
                    ratioButton(label: "9:16", ratio: 9/16)
                }
                .padding()
            }
            .background(Color.white.opacity(0.1))
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Logic
    
    private func calculateImageRect(containerSize: CGSize) {
        let imgSize = originalImage.size
        guard imgSize.width > 0, imgSize.height > 0, containerSize.width > 0, containerSize.height > 0 else { return }
        
        let aspect = imgSize.width / imgSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        var renderWidth: CGFloat
        var renderHeight: CGFloat
        
        if aspect > containerAspect {
            // Image is wider than container
            renderWidth = containerSize.width
            renderHeight = containerSize.width / aspect
        } else {
            // Image is taller than container
            renderHeight = containerSize.height
            renderWidth = containerSize.height * aspect
        }
        
        let x = (containerSize.width - renderWidth) / 2
        let y = (containerSize.height - renderHeight) / 2
        
        let newRect = CGRect(x: x, y: y, width: renderWidth, height: renderHeight)
        
        // Prevent layout loop/reset if value is stable
        if newRect != self.imageRect {
            self.imageRect = newRect
            // Only reset crop rect if it hasn't been set or is suspiciously zero
            if self.cropRect == .zero || self.cropRect.width < 1 {
                self.cropRect = newRect
            }
        }
    }
    
    private func ratioButton(label: String, ratio: CGFloat?) -> some View {
        Button {
            selectedRatio = ratio
            applyRatio(ratio)
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(
                    // Simple equality check for ratio might be tricky with floats, but ok for now
                    (ratio == nil && selectedRatio == nil) || 
                    (ratio != nil && selectedRatio != nil && abs(ratio! - selectedRatio!) < 0.01) 
                    ? .white : .gray
                )
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(
                            (ratio == nil && selectedRatio == nil) || 
                            (ratio != nil && selectedRatio != nil && abs(ratio! - selectedRatio!) < 0.01) 
                            ? Color.blue : Color.white.opacity(0.1)
                        )
                )
        }
    }
    
    private func applyRatio(_ ratio: CGFloat?) {
        guard let r = ratio else { return }
        
        // Try to fit new ratio within current image rect, centered
        let currentW = imageRect.width
        let currentH = imageRect.height
        
        var newW = currentW
        var newH = currentW / r
        
        if newH > currentH {
            newH = currentH
            newW = newH * r
        }
        
        let headerOffset = (currentH - newH) / 2
        let sideOffset = (currentW - newW) / 2
        
        // Animate change
        withAnimation {
            cropRect = CGRect(
                x: imageRect.minX + sideOffset,
                y: imageRect.minY + headerOffset,
                width: newW,
                height: newH
            )
        }
    }
    
    // Helper to downsample image for display
    private func downsample(image: UIImage, to pointSize: CGFloat) -> UIImage? {
        let maxDimension = max(image.size.width, image.size.height)
        if maxDimension <= pointSize { return image }
        
        let scale = pointSize / maxDimension
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    
    enum Corner { case topLeft, topRight, bottomLeft, bottomRight }
    enum Edge { case top, bottom, left, right }
    
    private func handle(at corner: Corner) -> some View {
        // Handle visual
        Circle()
            .fill(Color.white)
            .frame(width: 20, height: 20)
            .position(position(for: corner))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        resizeCropRect(corner: corner, translation: value.translation)
                    }
                    .onEnded { _ in
                        dragStartRect = nil
                    }
            )
    }
    
    private func sideHandle(for edge: Edge) -> some View {
        let isVertical = edge == .top || edge == .bottom
        return Rectangle()
            .fill(Color.white)
            .frame(width: isVertical ? 40 : 10, height: isVertical ? 10 : 40)
            .cornerRadius(5)
            .position(edgePosition(for: edge))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        resizeCropRectByEdge(edge: edge, translation: value.translation)
                    }
                    .onEnded { _ in
                        dragStartRect = nil
                    }
            )
    }
    
    private func edgePosition(for edge: Edge) -> CGPoint {
        switch edge {
        case .top: return CGPoint(x: cropRect.midX, y: cropRect.minY)
        case .bottom: return CGPoint(x: cropRect.midX, y: cropRect.maxY)
        case .left: return CGPoint(x: cropRect.minX, y: cropRect.midY)
        case .right: return CGPoint(x: cropRect.maxX, y: cropRect.midY)
        }
    }
    
    private func position(for corner: Corner) -> CGPoint {
        switch corner {
        case .topLeft: return CGPoint(x: cropRect.minX, y: cropRect.minY)
        case .topRight: return CGPoint(x: cropRect.maxX, y: cropRect.minY)
        case .bottomLeft: return CGPoint(x: cropRect.minX, y: cropRect.maxY)
        case .bottomRight: return CGPoint(x: cropRect.maxX, y: cropRect.maxY)
        }
    }
    
    @State private var dragStartRect: CGRect? = nil
    
    private func moveCropRect(_ translation: CGSize) {
        if dragStartRect == nil {
            dragStartRect = cropRect
        }
        
        guard let startRect = dragStartRect else { return }
        
        var newX = startRect.origin.x + translation.width
        var newY = startRect.origin.y + translation.height
        
        // Constrain to image text
        newX = max(imageRect.minX, min(newX, imageRect.maxX - startRect.width))
        newY = max(imageRect.minY, min(newY, imageRect.maxY - startRect.height))
        
        cropRect.origin = CGPoint(x: newX, y: newY)
    }
    
    private func resizeCropRect(corner: Corner, translation: CGSize) {
        if dragStartRect == nil {
            dragStartRect = cropRect
        }
        
        guard let startRect = dragStartRect else { return }
        
        var newRect = startRect
        
        switch corner {
        case .topLeft:
            newRect.origin.x += translation.width
            newRect.origin.y += translation.height
            newRect.size.width -= translation.width
            newRect.size.height -= translation.height
            
        case .topRight:
            newRect.origin.y += translation.height
            newRect.size.width += translation.width
            newRect.size.height -= translation.height
            
        case .bottomLeft:
            newRect.origin.x += translation.width
            newRect.size.width -= translation.width
            newRect.size.height += translation.height
            
        case .bottomRight:
            newRect.size.width += translation.width
            newRect.size.height += translation.height
        }
        
        // Constraints
        // 1. Min Size
        if newRect.width < minCropSize {
            // Adjust origin if needed based on corner
            if corner == .topLeft || corner == .bottomLeft {
                newRect.origin.x = startRect.maxX - minCropSize
            }
            newRect.size.width = minCropSize
        }
        if newRect.height < minCropSize {
            if corner == .topLeft || corner == .topRight {
                newRect.origin.y = startRect.maxY - minCropSize
            }
            newRect.size.height = minCropSize
        }
        
        // 2. Bounds (Image Rect)
        // This is complex for resizing, simplified constraint:
        // Ensure newRect is fully contained in imageRect
        if newRect.minX < imageRect.minX {
            newRect.size.width -= (imageRect.minX - newRect.minX)
            newRect.origin.x = imageRect.minX
        }
        if newRect.minY < imageRect.minY {
            newRect.size.height -= (imageRect.minY - newRect.minY)
            newRect.origin.y = imageRect.minY
        }
        if newRect.maxX > imageRect.maxX {
            newRect.size.width = imageRect.maxX - newRect.minX
        }
        if newRect.maxY > imageRect.maxY {
            newRect.size.height = imageRect.maxY - newRect.minY
        }
        
        cropRect = newRect
        
        // If resizing freely, clear the preset ratio
        if selectedRatio != nil {
            selectedRatio = nil
        }
    }
    
    private func resizeCropRectByEdge(edge: Edge, translation: CGSize) {
        if dragStartRect == nil {
            dragStartRect = cropRect
        }
        
        guard let startRect = dragStartRect else { return }
        
        var newRect = startRect
        
        switch edge {
        case .top:
            newRect.origin.y += translation.height
            newRect.size.height -= translation.height
        case .bottom:
            newRect.size.height += translation.height
        case .left:
            newRect.origin.x += translation.width
            newRect.size.width -= translation.width
        case .right:
            newRect.size.width += translation.width
        }
        
        // Constraints
        if newRect.width < minCropSize {
            if edge == .left {
                newRect.origin.x = startRect.maxX - minCropSize
            }
            newRect.size.width = minCropSize
        }
        if newRect.height < minCropSize {
            if edge == .top {
                newRect.origin.y = startRect.maxY - minCropSize
            }
            newRect.size.height = minCropSize
        }
        
        // Bounds
        if newRect.minX < imageRect.minX {
            newRect.size.width -= (imageRect.minX - newRect.minX)
            newRect.origin.x = imageRect.minX
        }
        if newRect.minY < imageRect.minY {
            newRect.size.height -= (imageRect.minY - newRect.minY)
            newRect.origin.y = imageRect.minY
        }
        if newRect.maxX > imageRect.maxX {
            newRect.size.width = imageRect.maxX - newRect.minX
        }
        if newRect.maxY > imageRect.maxY {
            newRect.size.height = imageRect.maxY - newRect.minY
        }
        
        cropRect = newRect
        
        if selectedRatio != nil {
            selectedRatio = nil
        }
    }
    
    // MARK: - Safe Crop Logic
    
    func performCrop() {
        // 1. Calculate relative crop rect (0...1)
        // Guard against zero width/height
        guard imageRect.width > 0, imageRect.height > 0, cropRect.width > 0, cropRect.height > 0 else { return }
        
        let relativeX = (cropRect.minX - imageRect.minX) / imageRect.width
        let relativeY = (cropRect.minY - imageRect.minY) / imageRect.height
        let relativeW = cropRect.width / imageRect.width
        let relativeH = cropRect.height / imageRect.height
        
        // 2. Map to original image coordinates
        let imgW = originalImage.size.width
        let imgH = originalImage.size.height
        
        let cropX = relativeX * imgW
        let cropY = relativeY * imgH
        let cropW = relativeW * imgW
        let cropH = relativeH * imgH
        
        let cropRectCG = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
        
        // 3. Perform crop using CoreGraphics
        guard let cgImage = originalImage.cgImage,
              let croppedCG = cgImage.cropping(to: cropRectCG) else {
            onCancel() // Fail safely
            return
        }
        
        let newImage = UIImage(cgImage: croppedCG, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        onCrop(newImage)
    }
}
