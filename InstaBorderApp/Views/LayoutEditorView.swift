import SwiftUI
import PhotosUI

struct LayoutEditorView: View {
    let template: LayoutTemplate
    let images: [UIImage]

    @StateObject private var viewModel: LayoutEditorViewModel
    @State private var showRatioSheet = false
    @State private var showColorSheet = false
    @State private var showBorderSheet = false
    @State private var isSaving = false
    @State private var showingSaveSuccess = false
    @State private var saveMessage = ""
    @State private var activeSlotIndex: Int? = nil  // For blue border and drag handles (tap or manipulation)
    @State private var showActionButtons: Bool = false  // For action buttons (long-press only)
    @State private var slotToAddPhoto: Int? = nil
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var editingSlotIndex: Int? = nil
    @State private var showPhotoEditor = false
    @State private var cropSlotIndex: Int? = nil
    @State private var cropImage: UIImage? = nil
    @State private var showCropOverlay = false
    @State private var isLoadingPhoto = false

    // Switch mode state
    @State private var isSwitchMode = false
    @State private var switchSourceSlotIndex: Int? = nil

    // Canvas zoom state
    @State private var canvasScale: CGFloat = 1.0
    @GestureState private var gesturePinchScale: CGFloat = 1.0
    
    // Text and sticker editing
    @State private var showTextEditor = false
    @State private var showStickerPicker = false
    @State private var editingTextElement: TextElement? = nil
    @State private var currentCanvasSize: CGSize = CGSize(width: 300, height: 375)

    @Environment(\.dismiss) var dismiss
    
    init(template: LayoutTemplate, images: [UIImage]) {
        self.template = template
        self.images = images
        self._viewModel = StateObject(wrappedValue: LayoutEditorViewModel(template: template, images: images))
    }
    
    var body: some View {
        mainContent
            .fullScreenCover(isPresented: $showPhotoEditor, content: photoEditorContent)
            .overlay {
                if showCropOverlay, let imageToEdit = cropImage, let slotIndex = cropSlotIndex {
                    ImageCropView(
                        originalImage: imageToEdit,
                        onCrop: { croppedImage in
                            viewModel.updatePhotoImage(croppedImage, at: slotIndex)
                            cropSlotIndex = nil
                            cropImage = nil
                            showCropOverlay = false
                        },
                        onCancel: {
                            cropSlotIndex = nil
                            cropImage = nil
                            showCropOverlay = false
                        }
                    )
                    .transition(.opacity)
                    .zIndex(1000)
                }
            }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            header
            canvasView
            controlsView
        }
        .background(Color.black)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $showRatioSheet) {
            RatioSheet(currentRatio: $viewModel.config.aspectRatio) {}
                .presentationDetents([.height(180)])
        }
        .sheet(isPresented: $showColorSheet) {
            ColorSheet(currentColor: $viewModel.config.backgroundColor) {}
                .presentationDetents([.height(220)])
        }
        .sheet(isPresented: $showBorderSheet) {
            BorderSheet(
                outerBorderWidth: $viewModel.config.outerBorderWidth,
                innerSpacing: $viewModel.config.innerSpacing,
                cornerRadius: $viewModel.config.cornerRadius,
                onEditingChanged: { editing in
                    if editing { viewModel.saveSnapshot() }
                }
            )
            .presentationDetents([.height(280)])
        }
        .overlay(savingOverlay)
        .alert(NSLocalizedString("alert.complete", comment: ""), isPresented: $showingSaveSuccess) {
            Button(NSLocalizedString("button.ok", comment: "")) {}
        } message: {
            Text(saveMessage)
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            handlePhotoSelection(newItem)
        }
        .onChange(of: showPhotoPicker) { _, isShowing in
            // Reset slotToAddPhoto when picker closes without selection
            if !isShowing && selectedPhotoItem == nil {
                slotToAddPhoto = nil
            }
        }
        // Text Editor overlay - shows canvas behind
        .overlay {
            if showTextEditor {
                TextEditorView(
                    textElement: $editingTextElement,
                    onSave: { textElement in
                        var element = textElement
                        if element.position == .zero {
                            // Default to center of canvas
                            element.position = CGPoint(x: currentCanvasSize.width / 2, y: currentCanvasSize.height / 2)
                        }
                        if let existing = editingTextElement {
                            viewModel.updateTextElement(existing.id, with: element)
                        } else {
                            viewModel.addTextElement(element)
                        }
                        editingTextElement = nil
                        showTextEditor = false
                    },
                    onDelete: {
                        // Delete text element when user clears all text
                        if let existing = editingTextElement {
                            viewModel.removeTextElement(existing.id)
                        }
                        editingTextElement = nil
                        showTextEditor = false
                    },
                    onCancel: {
                        // Cancel button tapped
                        editingTextElement = nil
                        showTextEditor = false
                    }
                )
                .transition(.opacity)
                .zIndex(1001)
            }
        }
        // Sticker Picker sheet
        .sheet(isPresented: $showStickerPicker) {
            StickerPickerView(
                onSelect: { stickerElement in
                    // Close sheet first, then add element
                    showStickerPicker = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.addStickerElement(stickerElement)
                    }
                },
                canvasCenter: CGPoint(x: currentCanvasSize.width / 2, y: currentCanvasSize.height / 2),
                onDismiss: {
                    showStickerPicker = false
                }
            )
        }
    }

    @ViewBuilder
    private var savingOverlay: some View {
        if isSaving {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView().tint(.white).scaleEffect(1.3)
                Text(NSLocalizedString("status.saving", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        } else if isLoadingPhoto {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView().tint(.white).scaleEffect(1.3)
                Text(NSLocalizedString("status.icloudDownload", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
    }

    @ViewBuilder
    private func photoEditorContent() -> some View {
        if let slotIndex = editingSlotIndex,
           let image = viewModel.photos[slotIndex].image {
            PhotoEditorView(originalImage: image, onSave: { adjustments in
                // Apply adjustments to the original image
                Task {
                    let engine = PhotoEditorEngine()
                    let editedImage = engine.render(image: image, adjustments: adjustments)
                    await MainActor.run {
                        viewModel.updatePhotoImage(editedImage, at: slotIndex)
                        showPhotoEditor = false
                        editingSlotIndex = nil
                    }
                }
            }, onCancel: {
                showPhotoEditor = false
                editingSlotIndex = nil
            })
        }
    }

    private func handlePhotoSelection(_ newItem: PhotosPickerItem?) {
        guard let item = newItem, let slotIndex = slotToAddPhoto else { return }

        isLoadingPhoto = true

        Task {
            defer {
                Task { @MainActor in
                    isLoadingPhoto = false
                    selectedPhotoItem = nil
                    slotToAddPhoto = nil
                    showPhotoPicker = false
                }
            }

            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    viewModel.setPhoto(image, at: slotIndex)
                }
            }
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            // Undo button
            Button {
                withAnimation {
                    viewModel.undo()
                }
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.canUndo ? .white : .gray)
            }
            .disabled(!viewModel.canUndo)

            // Reset button
            Button {
                withAnimation {
                    viewModel.reset()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.hasAdjustments ? .white : .gray)
            }
            .disabled(!viewModel.hasAdjustments)

            Text(NSLocalizedString("layout.editor", comment: "Layout"))
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Button(action: saveLayout) {
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
    }
    
    private var canvasView: some View {
        GeometryReader { geometry in
            let canvasWidth = geometry.size.width - 40
            let canvasHeight = canvasWidth / viewModel.config.aspectRatio
            let canvasSize = CGSize(width: canvasWidth, height: canvasHeight)
            let effectiveScale = canvasScale * gesturePinchScale
            
            // Content area (with outer border inset)
            let contentSize = CGSize(
                width: canvasSize.width - 2 * viewModel.config.outerBorderWidth,
                height: canvasSize.height - 2 * viewModel.config.outerBorderWidth
            )
            
            // Store content size for text/sticker positioning
            let _ = Task { @MainActor in
                if currentCanvasSize != contentSize {
                    currentCanvasSize = contentSize
                }
            }
            
            ZStack {
                // Full area background for gesture capture
                Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        activeSlotIndex = nil
                        showActionButtons = false
                    }
                
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    canvasContent(
                        canvasSize: canvasSize,
                        contentSize: contentSize,
                        effectiveScale: effectiveScale
                    )
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { _ in
                            showActionButtons = false
                        }
                )
                
                // Action buttons overlay (Edit, Crop, Delete) - shown on long-press
                if showActionButtons, let index = activeSlotIndex, viewModel.photos[index].hasImage {
                    HStack(spacing: 30) {
                        // Edit Button (Photo Adjustments)
                        Button {
                            editingSlotIndex = index
                            showPhotoEditor = true
                            activeSlotIndex = nil
                            showActionButtons = false
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 70, height: 70)
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }

                        // Crop Button
                        Button {
                            // Pre-capture image before presenting overlay
                            guard let imageToEdit = viewModel.photos[index].image else { return }
                            cropSlotIndex = index
                            cropImage = imageToEdit
                            activeSlotIndex = nil
                            showActionButtons = false
                            // Small delay for view stabilization
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showCropOverlay = true
                            }
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 70, height: 70)
                                Image(systemName: "crop")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }

                        // Delete Button
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            viewModel.removePhoto(at: index)
                            activeSlotIndex = nil
                            showActionButtons = false
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 70, height: 70)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }

                        // Switch Button
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            isSwitchMode = true
                            switchSourceSlotIndex = index
                            activeSlotIndex = nil
                            showActionButtons = false
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 70, height: 70)
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                    }
                }
            }
        }
        .background(Color.black)
    }
    
    @ViewBuilder
    private func canvasContent(canvasSize: CGSize, contentSize: CGSize, effectiveScale: CGFloat) -> some View {
        let slotsToRender = viewModel.appliedSlots
        
        ZStack {
            // Background with canvas zoom gesture
            Rectangle()
                .fill(viewModel.config.backgroundColor)
                .frame(width: canvasSize.width, height: canvasSize.height)
                .onTapGesture {
                    activeSlotIndex = nil
                    showActionButtons = false
                }
                .simultaneousGesture(
                    MagnificationGesture()
                        .updating($gesturePinchScale) { value, state, _ in
                            state = value
                        }
                        .onChanged { _ in
                            showActionButtons = false
                        }
                        .onEnded { value in
                            canvasScale *= value
                            canvasScale = max(0.3, min(4.0, canvasScale))
                        }
                )
            
            // Content container - centered in canvas
            ZStack {
                ForEach(0..<slotsToRender.count, id: \.self) { index in
                    let photo = viewModel.photos[index]
                    LayoutSlotView(
                        shape: slotsToRender[index],
                        photo: photo,
                        contentSize: contentSize,
                        edgeInsets: template.edgeInsets(for: index, innerSpacing: viewModel.config.innerSpacing),
                        cornerRadius: viewModel.config.cornerRadius,
                        sharedPointIndices: template.movablePointIndices(for: index),
                        isActive: activeSlotIndex == index,
                        isSwitchSource: isSwitchMode && switchSourceSlotIndex == index,
                        isSwitchMode: isSwitchMode,
                        onTap: {
                            if isSwitchMode, let sourceIndex = switchSourceSlotIndex {
                                // In switch mode: swap photos with animation
                                if index != sourceIndex {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.swapPhotos(slotA: sourceIndex, slotB: index)
                                    }
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                }
                                // Exit switch mode
                                isSwitchMode = false
                                switchSourceSlotIndex = nil
                            } else {
                                // Normal mode: tap sets active slot and shows drag handles
                                activeSlotIndex = index
                                showActionButtons = false
                            }
                        },
                        onBeginGesture: {
                            // Dismiss action buttons on drag, keep drag handles visible
                            showActionButtons = false
                            activeSlotIndex = index
                            viewModel.saveSnapshot()
                        },
                        onUpdate: { scale, offset in
                            viewModel.updatePhoto(at: index, scale: scale, offset: offset)
                        },
                        onLongPress: {
                            // Long-press shows action buttons
                            activeSlotIndex = index
                            showActionButtons = true
                        },
                        onAddPhoto: {
                            slotToAddPhoto = index
                            showPhotoPicker = true
                        }
                    )
                    // Force complete view recreation when photo changes
                    .id("\(photo.id)-\(photo.version)")
                }

                // Draggable lines overlay - show handles when slot is active
                DraggableLinesOverlay(
                    viewModel: viewModel,
                    contentSize: contentSize,
                    activeSlotIndex: activeSlotIndex
                )
                
                // Text elements layer (above slots)
                ForEach($viewModel.textElements) { $element in
                    TextElementView(
                        element: $element,
                        canvasSize: contentSize,
                        isSelected: viewModel.selectedElementId == element.id,
                        onSelect: {
                            viewModel.selectElement(element.id)
                        },
                        onManipulate: {
                            viewModel.saveSnapshot()
                            viewModel.bringTextToFront(element.id)
                        },
                        onDoubleTap: {
                            editingTextElement = element
                            showTextEditor = true
                        },
                        onUpdatePosition: { newPosition in
                            viewModel.updateTextPosition(element.id, position: newPosition)
                        },
                        onUpdateScale: { newScale in
                            viewModel.updateTextScale(element.id, scale: newScale)
                        },
                        onUpdateRotation: { newRotation in
                            viewModel.updateTextRotation(element.id, rotation: newRotation)
                        }
                    )
                    .zIndex(Double(element.zIndex))
                }

                // Sticker elements layer
                ForEach($viewModel.stickerElements) { $element in
                    StickerElementView(
                        element: $element,
                        canvasSize: contentSize,
                        isSelected: viewModel.selectedElementId == element.id,
                        onSelect: {
                            viewModel.selectElement(element.id)
                        },
                        onManipulate: {
                            viewModel.saveSnapshot()
                            viewModel.bringStickerToFront(element.id)
                        },
                        onUpdatePosition: { newPosition in
                            viewModel.updateStickerPosition(element.id, position: newPosition)
                        },
                        onUpdateScale: { newScale in
                            viewModel.updateStickerScale(element.id, scale: newScale)
                        },
                        onUpdateRotation: { newRotation in
                            viewModel.updateStickerRotation(element.id, rotation: newRotation)
                        }
                    )
                    .zIndex(Double(element.zIndex))
                }

                // Delete button for selected sticker elements only
                if let elementId = viewModel.selectedElementId {
                    let isStickerElement = viewModel.stickerElements.contains { $0.id == elementId }
                    
                    if isStickerElement {
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            viewModel.removeStickerElement(elementId)
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 70, height: 70)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                    }
                }
            }
            .frame(width: contentSize.width, height: contentSize.height)
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .scaleEffect(effectiveScale, anchor: .center)
        .frame(width: canvasSize.width * effectiveScale, height: canvasSize.height * effectiveScale)
    }
    
    private var controlsView: some View {
        VStack(spacing: 16) {
            // Action Buttons
            HStack(spacing: 40) {
                Button(action: {
                    viewModel.saveSnapshot()  // Save before ratio change
                    showRatioSheet = true
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "aspectratio")
                            .font(.system(size: 22))
                        Text(ratioLabel)
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                }

                Button(action: {
                    viewModel.saveSnapshot()  // Save before color change
                    showColorSheet = true
                }) {
                    VStack(spacing: 6) {
                        Circle()
                            .fill(viewModel.config.backgroundColor)
                            .frame(width: 24, height: 24)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        Text(NSLocalizedString("label.background", comment: ""))
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                }
                
                Button(action: {
                    viewModel.saveSnapshot()  // Save before border change
                    showBorderSheet = true
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "square.on.square.dashed")
                            .font(.system(size: 22))
                        Text(NSLocalizedString("label.border", comment: ""))
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                }
                
                // Add Text button
                Button {
                    editingTextElement = nil
                    showTextEditor = true
                } label: {
                    VStack(spacing: 4) {
                        Text("Aa")
                            .font(.system(size: 20, weight: .bold))
                        Text("文字")
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                }
                
                // Add Sticker button
                Button {
                    showStickerPicker = true
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 22))
                        Text(NSLocalizedString("Add Sticker", comment: ""))
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color.black)
    }
    
    private var ratioLabel: String {
        let ratio = viewModel.config.aspectRatio
        if abs(ratio - LayoutConfiguration.ratio1x1) < 0.01 { return "1:1" }
        if abs(ratio - LayoutConfiguration.ratio4x5) < 0.01 { return "4:5" }
        if abs(ratio - LayoutConfiguration.ratio16x9) < 0.01 { return "16:9" }
        if abs(ratio - LayoutConfiguration.ratio9x16) < 0.01 { return "9:16" }
        return String(format: "%.2f", ratio)
    }
    
    private func saveLayout() {
        isSaving = true
        viewModel.renderAndSave { success in
            isSaving = false
            saveMessage = success
                ? NSLocalizedString("alert.saved", comment: "Image saved successfully")
                : NSLocalizedString("alert.saveFailed", comment: "")
            showingSaveSuccess = true
        }
    }
}

// MARK: - Slider Control
struct SliderControl: View {
    let icon: String
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let label: String
    var onEditingChanged: ((Bool) -> Void)? = nil

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 20)
            Slider(value: $value, in: range, step: 1) { editing in
                onEditingChanged?(editing)
            }
                .tint(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 36)
        }
    }
}

// MARK: - Layout Slot View
struct LayoutSlotView: View {
    let shape: LayoutSlotShape
    let photo: LayoutPhoto
    let contentSize: CGSize
    let edgeInsets: EdgeInsets
    let cornerRadius: CGFloat
    let sharedPointIndices: Set<Int>?
    let isActive: Bool
    var isSwitchSource: Bool = false
    var isSwitchMode: Bool = false
    var onTap: (() -> Void)? = nil
    let onBeginGesture: () -> Void
    let onUpdate: (CGFloat, CGSize) -> Void
    var onLongPress: (() -> Void)? = nil
    var onAddPhoto: (() -> Void)? = nil

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var pinchScale: CGFloat = 1.0
    @State private var hasStartedGesture: Bool = false

    var body: some View {
        let shapePath = shape.path(in: contentSize, edgeInsets: edgeInsets, cornerRadius: cornerRadius, sharedPointIndices: sharedPointIndices)
        let boundingRect = shapePath.boundingRect

        Group {
            if photo.hasImage {
                slotContent(shapePath: shapePath, boundingRect: boundingRect)
            } else {
                emptySlotContent(shapePath: shapePath, boundingRect: boundingRect)
            }
        }
        .overlay(
            // Blue edge lines when active
            shapePath
                .stroke(Color.blue, lineWidth: 6)
                .opacity(isActive ? 1 : 0)
        )
        .overlay(
            // Switch mode indicators
            Group {
                if isSwitchSource {
                    // Orange glow for source slot
                    shapePath
                        .stroke(Color.orange, lineWidth: 8)
                        .shadow(color: .orange.opacity(0.6), radius: 10)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isSwitchSource)
                } else if isSwitchMode && photo.hasImage {
                    // Green glow for potential target slots
                    shapePath
                        .stroke(Color.green.opacity(0.5), lineWidth: 6)
                        .shadow(color: .green.opacity(0.3), radius: 8)
                }
            }
        )
        .scaleEffect(isSwitchSource ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSwitchSource)
        .onAppear {
            // Initialize from photo's saved transform
            scale = photo.scale
            offset = photo.offset
        }
        .onChange(of: photo.scale) { _, newScale in
            // Sync when photo's scale changes (e.g., from undo/reset)
            if !hasStartedGesture {
                scale = newScale
            }
        }
        .onChange(of: photo.offset) { _, newOffset in
            // Sync when photo's offset changes (e.g., from undo/reset)
            if !hasStartedGesture {
                offset = newOffset
            }
        }
    }

    private func calculateCentroid() -> CGPoint {
        switch shape {
        case .polygon(let points):
            // Calculate centroid of polygon
            var sumX: CGFloat = 0
            var sumY: CGFloat = 0
            for point in points {
                let scaledPoint = CGPoint(
                    x: point.x * contentSize.width,
                    y: point.y * contentSize.height
                )
                sumX += scaledPoint.x
                sumY += scaledPoint.y
            }
            return CGPoint(x: sumX / CGFloat(points.count), y: sumY / CGFloat(points.count))
        case .rectangle:
            let bounds = shape.path(in: contentSize, edgeInsets: edgeInsets, cornerRadius: cornerRadius, sharedPointIndices: sharedPointIndices).boundingRect
            return CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }

    private func emptySlotContent(shapePath: Path, boundingRect: CGRect) -> some View {
        let iconCenter = calculateCentroid()
        let iconSize = min(boundingRect.width, boundingRect.height) * 0.3

        return ZStack {
            // Slot background
            shapePath
                .fill(Color.gray.opacity(0.3))

            // Plus icon centered at shape centroid
            Button {
                onAddPhoto?()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: iconSize, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
            }
            .position(x: iconCenter.x, y: iconCenter.y)
        }
        .frame(width: contentSize.width, height: contentSize.height)
    }

    private func slotContent(shapePath: Path, boundingRect: CGRect) -> some View {

        GeometryReader { geometry in
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: boundingRect.width, height: boundingRect.height)
                    .scaleEffect(scale * pinchScale, anchor: .center)
                    .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                    .frame(width: contentSize.width, height: contentSize.height)
                    .position(x: boundingRect.midX, y: boundingRect.midY)
                    .clipShape(shapePath)
                    .contentShape(shapePath)  // Limit hit testing to the actual shape
                    .onTapGesture {
                        onTap?()
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                onLongPress?()
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !hasStartedGesture {
                                    hasStartedGesture = true
                                    onBeginGesture()
                                }
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                offset.width += value.translation.width
                                offset.height += value.translation.height
                                dragOffset = .zero
                                hasStartedGesture = false
                                onUpdate(scale, offset)
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if !hasStartedGesture {
                                    hasStartedGesture = true
                                    onBeginGesture()
                                }
                                pinchScale = value
                            }
                            .onEnded { value in
                                scale *= value
                                pinchScale = 1.0
                                hasStartedGesture = false
                                onUpdate(scale, offset)
                            }
                    )
            }
        }
        .frame(width: contentSize.width, height: contentSize.height)
    }
}

// MARK: - Border Sheet
struct BorderSheet: View {
    @Binding var outerBorderWidth: CGFloat
    @Binding var innerSpacing: CGFloat
    @Binding var cornerRadius: CGFloat
    var onEditingChanged: ((Bool) -> Void)?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(NSLocalizedString("label.border", comment: ""))
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top)
            
            // Sliders
            VStack(spacing: 16) {
                SliderControl(
                    icon: "square.on.square",
                    value: $outerBorderWidth,
                    range: 0...50,
                    label: String(format: "%.0f", outerBorderWidth),
                    onEditingChanged: onEditingChanged
                )
                
                SliderControl(
                    icon: "square.split.2x2",
                    value: $innerSpacing,
                    range: 0...30,
                    label: String(format: "%.0f", innerSpacing),
                    onEditingChanged: onEditingChanged
                )
                
                SliderControl(
                    icon: "circle",
                    value: $cornerRadius,
                    range: 0...50,
                    label: String(format: "%.0f", cornerRadius),
                    onEditingChanged: onEditingChanged
                )
            }
            .padding(.horizontal, 20)
            
            // Done Button
            Button(NSLocalizedString("button.done", comment: "")) {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

extension CGSize {
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
