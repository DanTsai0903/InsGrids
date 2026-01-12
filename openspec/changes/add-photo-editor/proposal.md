# Change: Add In-App Photo Editor

## Why

Users currently have to leave the app to apply filters or adjust photo properties (brightness, contrast, etc.) in the iOS Photos app or third-party tools. Providing a native editing experience allows users to perfect their photos directly within InsGrids before finalizing their borders or grid layouts.

## What Changes

### New Capabilities
- **Photo Adjustments**: Sliders for key parameters: Brightness, Contrast, Saturation, Exposure, Warmth, Vignette, Sharpness.
- **Filters**: Helper with preset filters (e.g., Vivid, Mono, Noir, Fade).
- **Non-Destructive Editing**: Edits are applied to a copy or proxy, preserving the original asset until export (or using a rendering pipeline).
- **Editor UI**: A dedicated editing view controller/sheet accessible from the canvas.

### User Interface Changes
- New **"Edit" button** in the photo context menu (alongside Crop, Delete).
- **Photo Editor Sheet**:
    - Large preview of the image.
    - Bottom tab bar: Adjustments vs Filters.
    - **Adjustment Mode**: Scrollable list of sliders (Icon + Name + Value).
    - **Filter Mode**: Horizontal scroll of preset thumbnails.
    - Top bar: Cancel / Done.
- Real-time preview of edits using CoreImage.

### Technical Changes
- **CoreImage Integration**: Use `CIContext` and `CIFilter` chains for processing.
- **Edit State Model**: Struct to store adjustment values (e.g., `PhotoAdjustments`).
- **ViewModel Update**: 
    - `BorderViewModel` and `GridViewModel` need to store `PhotoAdjustments` for each image.
    - `ImageProcessor` needs to apply these adjustments during the final export rendering.
- **Performance**: Use downsampled images for UI previews, apply to full-res only on export.

## Impact

### Affected Specs
- **New**: `photo-editing`
- **Modified**: `border-layout` (to support editable images), `freeform-grid` (to support editable images in cells)

### User Experience Impact
- Significantly richer workflow within the app.
- Users can fine-tune visual consistency across grid tiles.

### Compatibility
- Will require updating the persistence model (`BorderConfiguration` and `CanvasImage`) to store adjustment data.
- Migration strategy needed for existing saved states (default to no adjustments).
