## Context

The freeform grid layout feature enables users to create Instagram feed compositions by splitting images across multiple posts (1x2 to 3x3). This is a popular aesthetic used by brands and influencers to create cohesive, large-scale visual narratives on their Instagram profiles.

### Reference Example

![Instagram Grid Reference](/Users/tsaipingjui/.gemini/antigravity/brain/723b5712-1389-453d-985b-8b0eedf118fb/instagram_grid_reference.png)

The reference shows how professional accounts arrange images across multiple posts to create unified compositions when viewed as a profile grid.

### Background

Instagram displays profiles in a 3-column grid. By carefully splitting images across posts, users can create:
- Large hero images spanning 1x2, 2x2, or even 3x3 posts
- Coordinated multi-image layouts
- Visually striking feed aesthetics

Instagram's current post format uses **4:5 aspect ratio** (portrait), not 1:1 squares.

### Constraints

- **Memory**: Must maintain existing 12MP per-image limit to prevent crashes
- **Aspect Ratio**: Each tile must be 4:5 (Instagram's portrait format)
- **Platform**: iOS 26.0+ with SwiftUI, following existing MVVM architecture
- **Privacy**: No external dependencies, all processing on-device

## Goals / Non-Goals

### Goals

1. **Arbitrary Grid Configuration**: Support any NxM grid dimensions (e.g., 1x2, 2x3, 3x4, etc.)
2. **Image Slicing**: Accurately split images into equal tiles with 4:5 aspect ratio
3. **Freeform Arrangement**: Allow users to place multiple images in any grid cells
4. **Sequential Export**: Save numbered tiles in correct posting order
5. **Memory Safety**: Maintain existing memory management patterns
6. **Emoji Support**: Allow emoji overlays on individual cells
7. **Auto-Save**: Automatically preserve editing sessions
8. **Grid Presets**: Integrate with existing preset system for quick layout reuse

### Non-Goals

1. **Automatic Layout Suggestions**: No AI-powered layout recommendations (future feature)
2. **Advanced Editing**: No filters or stickers beyond emoji overlays
3. **Direct Instagram Posting**: No API integration with Instagram (user posts manually)
4. **Collaborative Grids**: No multi-user or cloud sync features

## Decisions

### Decision 1: Grid Data Model

**Choice**: Struct-based model with `GridLayout` containing array of `GridCell` objects, emoji data, and Codable conformance

```swift
struct GridLayout: Codable, Identifiable {
    var id: UUID = UUID()
    var rows: Int
    var columns: Int
    var cells: [[GridCell]]
    var createdDate: Date = Date()
}

struct GridCell: Codable {
    var row: Int
    var column: Int
    var assignedImage: UUID?  // Reference to image in ViewModel
    var imageScale: CGFloat = 1.0
    var imageOffset: CGSize = .zero
    var emoji: String? = nil
    var backgroundColor: Color? = nil
}
```

**Rationale**:
- Follows existing `BorderConfiguration` pattern (struct + Codable)
- Enables preset support for grid layouts (save/load via PresetManager)
- Enables auto-save functionality via UserDefaults
- Clean separation between layout config and actual image data
- Emoji stored as String (native Swift emoji support)

**Alternatives Considered**:
- **Class-based with Identifiable**: More complex, unnecessary reference semantics
- **Flat array of cells**: Harder to reason about row/column structure

### Decision 2: Image Slicing Strategy

**Choice**: Create final composite image first, then slice into 4:5 tiles

**Algorithm**:
1. Calculate final composite size (rows × columns, 4:5 per cell)
2. Render all placed images and emoji onto composite canvas
3. Slice composite into equal 4:5 tiles
4. Apply 12MP limit to each tile independently

**Aspect Ratio Math**:
- Each tile: 4:5 portrait (800px × 1000px for example)
- 2×3 grid total: 1600px × 3000px composite

**Rationale**:
- Ensures pixel-perfect alignment between tiles
- Simpler than tracking individual cell renders
- Matches how Instagram displays the grid in portrait format
- Emoji rendered as text overlays using CoreGraphics

**Alternatives Considered**:
- **Render each tile independently**: Risk of subpixel misalignment at tile boundaries
- **Vector-based approach**: Overly complex for raster images

### Decision 3: User Interface Pattern

**Choice**: Canvas-based editing with grid overlay, dimension picker, and emoji support

**Design**:
- Custom dimension picker: stepper or text input for rows/columns (1-6 max)
- Quick presets: 1×2, 2×2, 2×3, 3×3 as common options
- Grid cells displayed as outlined rectangles (4:5 ratio)
- Drag images from library panel onto grid cells
- Pinch/pan gestures to adjust image within cell
- Tap cell to add emoji overlay
- Real-time preview of full composition

**Rationale**:
- Arbitrary dimensions provide maximum flexibility
- Common presets speed up workflow
- Emoji tap interaction is simple and intuitive
- Familiar gesture patterns (drag, pinch, pan)

**Alternatives Considered**:
- **List-based cell assignment**: Less intuitive, harder to visualize final result
- **Auto-fill mode**: Removes creative control, not "freeform"

### Decision 4: Export File Naming

**Choice**: Sequential numbering with posting order annotation

**Format**: `InsGrids_Grid_1.jpg`, `InsGrids_Grid_2.jpg`, ..., `InsGrids_Grid_N.jpg`

**Order**: Left-to-right, top-to-bottom (matches Instagram posting order)

Example for 2x3 grid:
```
[1] [2] [3]
[4] [5] [6]
```

**Rationale**:
- Clear posting order for users
- Standard left-to-right, top-to-bottom convention
- Prevents confusion about which tile to post next

**Alternatives Considered**:
- **Row-column notation** (`grid_r1_c1.jpg`): More verbose, harder to remember order
- **Random order**: Would require additional sorting UI

### Decision 5: Memory Management for Large Grids

**Choice**: Process tiles serially with autoreleasepool, same as existing batch processing

**Strategy**:
1. Generate composite on background thread
2. Slice into tiles sequentially (one at a time)
3. Wrap each tile generation in autoreleasepool
4. Save tiles synchronously with semaphore pattern
5. 4:5 ratio reduces total pixels vs 1:1, slightly better memory profile

**Rationale**:
- Proven approach from existing `PhotoEditorViewModel.processAndSaveAll`
- Consistent memory profile with current app behavior
- Prevents memory spikes even for large grids (e.g., 4×6 = 24 tiles)

### Decision 6: Grid Preset Integration

**Choice**: Extend existing PresetManager to support GridLayout presets

**Implementation**:
```swift
enum PresetType: Codable {
    case border(BorderConfiguration)
    case grid(GridLayout)
}

struct Preset: Codable {
    var id: UUID
    var name: String
    var type: PresetType
    var createdDate: Date
}
```

**Rationale**:
- Reuses existing preset infrastructure
- Unified preset UI (filter by type)
- Consistent user experience

**Alternatives Considered**:
- **Separate GridPresetManager**: More code duplication
- **No preset support**: Missed opportunity for user convenience

---

### Decision 7: Auto-Save Mechanism

**Choice**: Auto-save grid state to UserDefaults every 3 seconds during editing

**Implementation**:
- Key: `com.insgrids.autosave.grid`
- Store: Current GridLayout + image references (UUIDs)
- Restore: On GridEditingView appear, check for saved state
- Clear: On successful export or explicit user discard

**Rationale**:
- UserDefaults sufficient for single grid session
- Existing pattern (used for border presets)
- Lightweight, no additional frameworks needed

**Alternatives Considered**:
- **Document-based storage**: Overkill for single session
- **Manual save only**: Risk of data loss on app crash

---

### Decision 8: Emoji Rendering

**Choice**: Render emoji as text using CoreGraphics string drawing

**Implementation**:
```swift
let emojiText = "😊"
let attributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 120),
    .foregroundColor: UIColor.white
]
emojiText.draw(at: CGPoint(x: 100, y: 100), withAttributes: attributes)
```

**Position**: Center of cell, above image layer

**Rationale**:
- Native Swift emoji support
- No external libraries needed
- Consistent rendering across devices

**Alternatives Considered**:
- **Emoji picker library**: Unnecessary dependency
- **Image-based emoji**: Accessibility issues


## Risks / Trade-offs

### Risk 1: Increased Complexity
**Impact**: New mental model for users (grid vs single-photo mode, emoji overlays, presets)

**Mitigation**:
- Keep modes clearly separated in UI
- Add first-time tutorial/help screen
- Provide visual examples in app
- Auto-save reduces learning curve (can experiment safely)

### Risk 2: Grid Tile Misalignment
**Impact**: Tiles may not align perfectly when posted to Instagram

**Mitigation**:
- Use precise pixel calculations with no rounding until final step
- Test with actual Instagram profile to verify alignment
- Add "preview grid" mode showing tiles with spacing

### Risk 3: Memory Pressure on Large Grids
**Impact**: Arbitrary grid sizes (e.g., 5×6 = 30 tiles) could cause memory issues

**Mitigation**:
- Serial processing (already implemented pattern)
- 12MP limit per tile
- 4:5 ratio uses ~20% fewer pixels than 1:1
- autoreleasepool cleanup
- Warn users if grid exceeds recommended size (e.g., > 4×4 = 16 tiles)
- Optional: Low-memory mode that reduces tile quality

### Risk 4: User Error in Posting Order
**Impact**: Users may post tiles in wrong order, breaking the grid

**Mitigation**:
- Large, clear numbering on each exported tile (in filename and photo metadata)
- Optional: Add posting order diagram in success alert
- Future: Interactive posting checklist

### Risk 5: Emoji Rendering Consistency
**Impact**: Emoji may look different on different iOS versions or devices

**Mitigation**:
- Use system font for emoji (Apple's native rendering)
- Test on multiple devices (iPhone SE, Pro Max)
- Provide emoji size adjustment slider
- Allow users to reposition emoji within cell


## Migration Plan

N/A - This is a new feature with no existing data to migrate.

## Validation Plan

### Unit Testing (Future)
- Test GridProcessor tile slicing accuracy
- Verify tile dimensions are correct 1:1 ratios
- Test cell assignment and overlap detection

### Manual Testing Checklist
1. Create 1x2, 2x2, 2x3, 3x3 grids
2. Fill grids with various image sizes (portrait, landscape, square)
3. Verify exported tiles align when placed in Instagram grid layout
4. Test memory usage on device with Activity Monitor
5. Verify all tiles are numbered correctly
6. Test with maximum complexity: 3x3 grid with 9 different 48MP photos

### Instagram Validation
1. Create test Instagram account
2. Post exported tiles in numbered order
3. Verify grid displays correctly in profile view
4. Check for any gaps or misalignments

## Open Questions

**All questions have been resolved:**

1. ✅ **Empty cells**: Fill with background color (optional color picker)
2. ✅ **Grid presets**: Yes, integrate with existing PresetManager
3. ✅ **Grid dimensions**: Arbitrary NxM (with common presets for quick access)
4. ✅ **Tile spacing**: No visible borders in exported tiles
