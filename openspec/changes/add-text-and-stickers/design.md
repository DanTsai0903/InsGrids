# Design Document: Text and Sticker Elements

## Overview

This document captures the architectural decisions for adding **text** and **sticker** capabilities to the InsGrids freeform canvas. While text and stickers are **separate functional areas** (defined in distinct spec deltas), they share common infrastructure components:

- **Shared**: Unified `CanvasElement` model, gesture system, persistence, export pipeline
- **Independent**: Text editing UI vs. Sticker picker UI, distinct element properties, separate requirements

This modular design allows text and stickers to be developed, tested, and potentially disabled independently while benefiting from shared infrastructure.

## Context

### Current Architecture

**Model Layer:**
- `CanvasImage` (in `GridCanvasView.swift:4-15`): Simple struct with `id`, `image`, `position`, `scale`, `rotation`, and `adjustments`
- `SavedCanvasImage`: Codable version for persistence (stores metadata only, excludes UIImage)
- Images stored separately: proxy images (1200px) in memory, originals on disk at `/Caches/original_images/{uuid}.jpg`

**ViewModel:**
- `GridViewModel`: Manages `@Published var canvasImages: [CanvasImage]`
- Auto-save every 5 seconds: serializes `SavedCanvasImage` metadata to UserDefaults, proxy images to `/Caches/autosave_images/`
- Undo/redo: Snapshots entire `canvasImages` array (lightweight value-type copies)
- Export: Loads high-res originals and renders to tiles via `UIGraphicsImageRenderer`

**View Layer:**
- `FreeformCanvasView`: Container managing canvas-level gestures (pinch-zoom)
- `SingleImageView`: Individual image with drag, scale, rotate gestures + snapping logic
- `EmojiPickerView`: Existing component with 8 categories, 20 emoji each

## Design Decisions

### 1. Unified Element Model

**Decision:** Create `CanvasElement` enum to unify Image, Text, and Sticker types.

**Rationale:**
- **Type Safety**: Enum with associated values provides compile-time guarantees
- **Shared Behavior**: All elements share transform properties (position, scale, rotation)
- **Codable**: Swift enums with associated values are naturally Codable
- **Pattern Reuse**: Mirror existing `CanvasImage` structure for consistency
- **Modularity**: Text and stickers can be developed as independent capabilities sharing this foundation

**Structure:**
```swift
enum CanvasElement: Identifiable, Codable {
    case image(ImageElement)
    case text(TextElement)
    case sticker(StickerElement)
    
    var id: UUID {
        switch self {
        case .image(let element): return element.id
        case .text(let element): return element.id
        case .sticker(let element): return element.id
        }
    }
    
    // Shared transform accessors via computed properties
    var position: CGPoint { get set }
    var scale: CGFloat { get set }
    var rotation: Angle { get set }
}
```

**Trade-offs:**
- ✅ **Pro**: Clean API, type-safe, easy to extend
- ✅ **Pro**: Switch statements ensure exhaustive handling
- ⚠️ **Con**: Accessing nested properties requires switching (acceptable, idiomatic Swift)

### 2. Migration Strategy

**Decision:** Dual-model approach during transition, full migration on auto-save restore.

**Plan:**
1. **Phase 1** (Tasks 2.1-2.5): Keep both `images: [CanvasImage]` and `elements: [CanvasElement]` in GridViewModel
2. **Phase 2** (On first restore): Migrate `CanvasImage` → `CanvasElement.image(ImageElement)` and remove old array
3. **Backward Compatibility**: Detect old `GridAutoSaveConfig` format, convert on load, save in new format

**Rationale:**
- Minimizes risk of breaking existing functionality during development
- Provides clean cutover point (auto-save restore)
- Users won't lose existing sessions

**Migration Logic:**
```swift
func restoreSession() {
    if let data = UserDefaults.standard.data(forKey: autoSaveKey) {
        // Try new format first
        if let config = try? JSONDecoder().decode(GridAutoSaveConfigV2.self, from: data) {
            elements = config.elements
        }
        // Fallback to old format
        else if let oldConfig = try? JSONDecoder().decode(GridAutoSaveConfig.self, from: data) {
            elements = oldConfig.images.map { .image(ImageElement(from: $0)) }
        }
    }
}
```

### 3. Text Editing Interaction

**Decision:** Double-tap to edit existing text (not single tap).

**Rationale:**
- **Conflict Avoidance**: Single tap conflicts with drag gesture initiation
- **iOS Conventions**: Double-tap for editing is standard (e.g., Notes, Pages)
- **Accidental Prevention**: Less likely to trigger during repositioning

**Note:** Initial text creation opens editor immediately on "Add Text" button tap.

### 4. Font Availability

**Decision:** Limit to system fonts guaranteed on all iOS versions (iOS 13+).

**Font List:**
- **Sans-serif**: SF Pro Text (default), Helvetica Neue, Arial
- **Serif**: Georgia, Times New Roman
- **Monospace**: Courier New, Menlo

**Validation:** Add runtime check with fallback:
```swift
let requestedFont = "Georgia"
let availableFonts = UIFont.familyNames
let fontToUse = UIFont(name: requestedFont, size: 24) != nil ? requestedFont : "SF Pro Text"
```

**Task Addition:** Insert new task 3.2.1 for font availability validation.

### 5. SF Symbols Catalog

**Decision:** Curate 15-20 symbols per category, use .fill variants where available.

**Extended Catalog:**
- **Arrows**: `arrow.up`, `arrow.down`, `arrow.left`, `arrow.right`, `arrow.up.circle.fill`, `arrow.down.circle.fill`, `arrow.left.circle.fill`, `arrow.right.circle.fill`, `arrow.turn.up.right`, `arrow.turn.down.left`, `arrow.uturn.backward`, `arrow.uturn.forward`, `arrow.clockwise`, `arrow.counterclockwise`, `chevron.up`, `chevron.down`
- **Shapes**: `circle.fill`, `square.fill`, `triangle.fill`, `heart.fill`, `star.fill`, `diamond.fill`, `hexagon.fill`, `octagon.fill`, `shield.fill`, `flag.fill`, `bookmark.fill`, `cloud.fill`, `moon.fill`, `sun.max.fill`, `sparkle`
- **Communication**: `message.fill`, `phone.fill`, `envelope.fill`, `paperplane.fill`, `bubble.left.fill`, `bubble.right.fill`, `ellipsis.bubble.fill`, `quote.bubble.fill`, `text.bubble.fill`, `exclamationmark.bubble.fill`, `questionmark.bubble.fill`, `mic.fill`, `speaker.wave.2.fill`, `bell.fill`, `video.fill`
- **Weather**: `sun.max.fill`, `cloud.fill`, `cloud.rain.fill`, `cloud.snow.fill`, `cloud.bolt.fill`, `moon.stars.fill`, `sparkles`, `wind`, `tornado`, `hurricane`, `snowflake`, `thermometer.sun.fill`, `thermometer.snowflake`, `drop.fill`, `humidity.fill`
- **Nature**: `leaf.fill`, `flame.fill`, `drop.fill`, `snowflake`, `sparkles`, `tree.fill`, `mountain.2.fill`, `sunrise.fill`, `sunset.fill`, `moon.fill`, `star.fill`, `cloud.sun.fill`, `cloud.moon.fill`, `rainbow`, `flower`
- **Objects**: `lightbulb.fill`, `camera.fill`, `music.note`, `gift.fill`, `book.fill`, `bookmark.fill`, `graduationcap.fill`, `briefcase.fill`, `hammer.fill`, `wrench.fill`, `paintbrush.fill`, `cup.and.saucer.fill`, `cart.fill`, `bag.fill`, `key.fill`

**Rationale:** Balance between variety and overwhelming users. Search functionality mitigates discoverability.

### 6. Z-Order Controls Scope

**Decision:** Add Z-order controls (Bring to Front / Send to Back) to **all element types**, including images.

**Rationale:**
- **Consistency**: Users expect same controls across all canvas elements
- **Necessary for Images**: Layering images with text/stickers requires Z-order control
- **UI Simplification**: Same action overlay for all element types reduces cognitive load

**Implementation:** Update existing image action overlay (currently Edit, Crop, Delete) to include Z-order buttons.

### 7. Export Rendering Strategy

**Decision:** Single-pass rendering in array order (not multi-pass by type).

**Rationale:**
- **Correct Layering**: Array order = Z-order, single pass preserves this
- **Simpler Logic**: No need to partition elements by type
- **Performance**: One iteration vs. three separate passes

**Rendering Approach:**
```swift
for element in elements {
    switch element {
    case .image(let img):
        renderImageElement(img, on: context, scale: exportScale)
    case .text(let txt):
        renderTextElement(txt, on: context, scale: exportScale)
    case .sticker(let stk):
        renderStickerElement(stk, on: context, scale: exportScale)
    }
}
```

### 8. High-Resolution Text Rendering

**Decision:** Use CoreText with NSAttributedString for text export, UIImage(systemName:) for SF Symbols.

**Text Rendering:**
- Calculate export font size: `fontSize * element.scale * exportScale`
- Create `NSAttributedString` with `NSFont` at calculated size
- Draw using `CTFramesetterCreateWithAttributedString` + `CTFrameDraw`
- For background: draw `CGRect` with fill color and opacity before text

**Symbol Rendering:**
- Use `UIImage(systemName:, withConfiguration:)` with `UIImage.SymbolConfiguration(pointSize:weight:)`
- Calculate size: `symbolSize * element.scale * exportScale`
- Apply tint color via `withTintColor()` before drawing
- Prevents pixelation vs. scaling raster image

**Emoji Rendering:**
- Use `NSAttributedString` with large font size (not image scaling)
- iOS renders emoji as vector glyphs, scales cleanly

### 9. Cross-Tile Element Handling

**Decision:** Render full element on each tile it intersects, clipped to tile bounds.

**Rationale:**
- **Simplicity**: No complex splitting logic
- **Correctness**: CGContext clipping ensures pixel-perfect alignment
- **Performance**: Overdraw is minimal (text/stickers are lightweight)

**Implementation:**
```swift
for tile in tiles {
    let renderer = UIGraphicsImageRenderer(size: tileSize)
    let tileImage = renderer.image { context in
        // Set clip region to tile bounds
        context.cgContext.clip(to: CGRect(origin: .zero, size: tileSize))
        
        // Render elements (full elements, clipped by context)
        for element in elementsIntersecting(tile) {
            renderElement(element, in: tile, context: context.cgContext)
        }
    }
}
```

## Open Questions

### 1. Text Element Default Position
**Question:** Should new text elements always appear at canvas center, or intelligently offset if center is occupied?

**Recommendation:** Start with center (simplicity), iterate based on user feedback. Power users can drag immediately.

### 2. Sticker Color Customization
**Question:** Should emoji stickers also support color tinting (iOS 15+ feature)?

**Recommendation:** No, only SF Symbols. Emoji tinting is non-standard and may confuse users expecting standard emoji appearance.

### 3. Element Selection Visual Feedback
**Question:** Should selected elements show a visual border or glow, in addition to action buttons?

**Recommendation:** Yes, add subtle white glow or border to clearly indicate selected state. Update spec/tasks accordingly.

### 4. Maximum Element Count
**Question:** Should we limit total elements per canvas (e.g., 50) to prevent performance issues?

**Recommendation:** Add soft limit (50 elements) with warning dialog. Text/stickers are lightweight but export complexity grows.

## References

- Existing Implementation: `GridCanvasView.swift:4-555`, `GridViewModel.swift:7-656`
- Gesture Patterns: `SingleImageView:312-529` (drag, scale, rotate, snap)
- Auto-Save: `GridViewModel:201-285` (saveState, restoreSession, clearAutoSave)
- Export: `GridViewModel:305-372` (generateTiles, renderCanvas)
