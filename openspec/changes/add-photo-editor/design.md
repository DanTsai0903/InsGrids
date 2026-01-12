# Photo Editor Design

## Context
We need to provide photo editing capabilities (filters, adjustments) inside the app. iOS's native `PHContentEditingController` is not suitable for our lightweight, non-destructive workflow on arbitrary `UIImage` instances (often copies from the library).

## Goals
1.  **Real-time Performance**: Adjustments must feel responsive (~60fps preview).
2.  **High Quality Export**: Edits must be applied to the full-resolution image on export.
3.  **Non-Destructive**: Original images should ideally remain untouched; we store a "recipe" of edits.

## Decisions

### Decision 1: Editing Pipeline
**Choice**: `CoreImage` with `CIFilter` chain.

**Implementation**:
- Use `CIImage` backed by the original `UIImage`.
- Apply a chain of filters based on a `PhotoAdjustments` struct.
- Use `CIContext` (Metal-accelerated) to render the preview.

**Filter Chain Order**:
1.  **Exposure** (`CIExposureAdjust`)
2.  **White Balance** (`CITemperatureAndTint` - for Warmth)
3.  **Basic Adjustments** (`CIColorControls` - Brightness, Contrast, Saturation)
4.  **Vignette** (`CIVignette`)
5.  **Sharpen** (`CISharpenLuminance`)
6.  **LUT/Preset** (`CIColorCube` or `CIPhotoEffect...`)

### Decision 2: Data Model
**Choice**: Store adjustments as a pure struct `PhotoAdjustments`.

```swift
struct PhotoAdjustments: Codable, Equatable {
    var brightness: Double = 0.0 // -0.5 to 0.5
    var contrast: Double = 1.0   // 0.5 to 1.5
    var saturation: Double = 1.0 // 0.0 to 2.0
    var exposure: Double = 0.0   // -2.0 to 2.0
    var warmth: Double = 0.0     // -1.0 to 1.0 (Temperature)
    var vignette: Double = 0.0   // 0.0 to 1.0
    var sharpness: Double = 0.0  // 0.0 to 1.0
    var filterName: String? = nil
}
```

This struct will be embedded into `CanvasImage` (Grid mode) and `BorderConfiguration` (Border mode).

### Decision 3: UI Architecture
**Choice**: Standalone `PhotoEditorView` presented as a full-screen sheet.

- **State**: Holds a local copy of `PhotoAdjustments`.
- **Preview**: `Image` view updated via a `Combine` publisher to throttle CoreImage rendering (prevent UI stutter).
- **Cancel**: Discard local changes.
- **Done**: Callback with new `PhotoAdjustments`; parent view updates model and re-renders thumbnail.

### Decision 4: Filter Presets
**Choice**: Use `CIPhotoEffect` built-ins first for simplicity.
- Mono, Noir, Fade, Chrome, Process, Transfer, Instant.
- Future: Custom LUT support if needed.

## Risks
- **Memory Usage**: `CIContext` can be memory intensive. Use `downsampled` images for the editing preview.
- **Complexity**: Managing the filter chain efficiently requires care (reusing CIContext).

## Schema Changes
- Update `CanvasImage` in `GridCanvasView.swift` to include `adjustments: PhotoAdjustments`.
- Update `BorderConfiguration` (or related model) to include `adjustments`.
