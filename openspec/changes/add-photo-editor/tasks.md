# Tasks: Add In-App Photo Editor

## 1. Core Logic & Models
- [ ] 1.1 Create `PhotoAdjustments` model (Codable, Equatable)
- [ ] 1.2 Implement `PhotoEditorEngine` (Helper class wrapping CoreImage logic)
    - [ ] 1.2.1 Filter chain implementation
    - [ ] 1.2.2 Rendering method (`render(uiImage:adjustments:) -> UIImage`)
- [ ] 1.3 Add standard CIPhotoEffect presets support

## 2. User Interface (PhotoEditorView)
- [ ] 2.1 Scaffold `PhotoEditorView` (Sheet presentation)
- [ ] 2.2 Implement Image Preview area (using downsampled image)
- [ ] 2.3 Implement Adjustment Sliders UI (Brightness, Contrast, etc.)
- [ ] 2.4 Implement Filter Selector UI (Horizontal scroll)
- [ ] 2.5 Connect UI sliders to `PhotoEditorEngine` with debounce/throttling

## 3. Integration - Data Models
- [ ] 3.1 Update `CanvasImage` (Grid Mode) to include `adjustments: PhotoAdjustments`
- [ ] 3.2 Update `PhotoEditorViewModel` (Border Mode) to support adjustments
    - *Note: Might need to refactor Border Mode to store image state more explicitly*

## 4. Integration - User Flows
- [ ] 4.1 **Grid Mode**: Add "Edit" button to contextual menu (Crop/Delete/Edit)
- [ ] 4.2 **Grid Mode**: Launch Editor -> Apply changes -> Update CanvasImage
- [ ] 4.3 **Border Mode**: Add "Edit" button to toolbar
- [ ] 4.4 **Border Mode**: Launch Editor -> Apply changes -> Update displayed image

## 5. Export Pipeline
- [ ] 5.1 Update `ImageExporter` / `GridProcessor` to apply adjustments to high-res originals before slicing/saving
- [ ] 5.2 Verify memory usage during export with heavy filters

## 6. Localization
- [ ] 6.1 Localize adjustment names (Brightness, Contrast, etc.)
- [ ] 6.2 Localize filter names
