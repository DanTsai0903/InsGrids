# Tasks: Add In-App Photo Editor

## 1. Core Logic & Models
- [x] 1.1 Create `PhotoAdjustments` model (Codable, Equatable)
- [x] 1.2 Implement `PhotoEditorEngine` (Helper class wrapping CoreImage logic)
    - [x] 1.2.1 Filter chain implementation
    - [x] 1.2.2 Rendering method (`render(uiImage:adjustments:) -> UIImage`)
- [x] 1.3 Add standard CIPhotoEffect presets support

## 2. User Interface (PhotoEditorView)
- [x] 2.1 Scaffold `PhotoEditorView` (Sheet presentation)
- [x] 2.2 Implement Image Preview area (using downsampled image)
- [x] 2.3 Implement Adjustment Sliders UI (Brightness, Contrast, etc.)
- [x] 2.4 Implement Filter Selector UI (Horizontal scroll)
- [x] 2.5 Connect UI sliders to `PhotoEditorEngine` with debounce/throttling

## 3. Integration - Data Models
- [x] 3.1 Update `CanvasImage` (Grid Mode) to include `adjustments: PhotoAdjustments`
- [x] 3.2 Update `SavedCanvasImage` to persist adjustments

## 4. Integration - User Flows
- [x] 4.1 **Grid Mode**: Add "Edit" button to contextual menu (Crop/Delete/Edit)
- [x] 4.2 **Grid Mode**: Launch Editor -> Apply changes -> Update CanvasImage
- [ ] 4.3 **Border Mode**: Add "Edit" button to toolbar
- [ ] 4.4 **Border Mode**: Launch Editor -> Apply changes -> Update displayed image

## 5. Export Pipeline
- [x] 5.1 Update `GridProcessor` to apply adjustments to high-res originals before slicing/saving
- [ ] 5.2 Verify memory usage during export with heavy filters

## 6. Localization
- [ ] 6.1 Localize adjustment names (Brightness, Contrast, etc.)
- [ ] 6.2 Localize filter names
