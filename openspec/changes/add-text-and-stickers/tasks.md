# Implementation Tasks

## 1. Data Model & Architecture

- [ ] 1.1 Create `InstaBorderApp/Models/CanvasElement.swift` with enum supporting Image, Text, and Sticker cases
  - Define `enum CanvasElement: Identifiable, Codable`
  - Case `.image(ImageElement)` - wraps existing CanvasImage data
  - Case `.text(TextElement)` - text with formatting
  - Case `.sticker(StickerElement)` - emoji or SF Symbol
  - Each case has `id: UUID`, `position: CGPoint`, `scale: CGFloat`, `rotation: Angle`

- [ ] 1.2 Define `ImageElement` struct to wrap existing CanvasImage properties
  - `image: UIImage` (proxy, 1200px)
  - `originalImageId: UUID?` (for loading from `/Caches/original_images/`)
  - `adjustments: PhotoAdjustments`
  - Codable using existing CanvasImage encoding logic

- [ ] 1.3 Define `TextElement` struct with properties
  - `text: String`
  - `font: String` (font name, e.g., "SF Pro", "Helvetica")
  - `fontSize: CGFloat` (12-72pt)
  - `color: Color` (text color, use existing Color Codable extension)
  - `alignment: TextAlignment` (left, center, right)
  - `backgroundColor: Color?` (nil = transparent)
  - `backgroundOpacity: Double` (0.0 = transparent, 1.0 = solid)

- [ ] 1.4 Define `StickerElement` struct with properties
  - `type: StickerType` enum (emoji, sfSymbol)
  - `content: String` (emoji character or SF Symbol name)
  - `color: Color?` (for SF Symbols, nil for emoji)
  - `size: CGFloat` (base size before scale transform)

- [ ] 1.5 Add computed properties to CanvasElement for unified access
  - `var id: UUID` - returns element's unique ID
  - `var position: CGPoint` - get/set position regardless of type
  - `var scale: CGFloat` - get/set scale regardless of type
  - `var rotation: Angle` - get/set rotation regardless of type

## 2. GridViewModel Extension

- [ ] 2.1 Update `GridViewModel.swift` to use new CanvasElement model
  - Keep existing `images: [CanvasImage]` temporarily for migration
  - Add `@Published var elements: [CanvasElement] = []`
  - Add migration function to convert old `CanvasImage` to `CanvasElement.image(ImageElement)`

- [ ] 2.2 Add element management methods to GridViewModel
  - `func addImageElement(_ image: UIImage, at position: CGPoint)` - wrap existing addImage logic
  - `func addTextElement(text: String, font: String, fontSize: CGFloat, color: Color, at position: CGPoint)`
  - `func addStickerElement(type: StickerType, content: String, at position: CGPoint)`
  - `func updateElement(id: UUID, with updatedElement: CanvasElement)`
  - `func deleteElement(id: UUID)` - remove by ID and add to undo stack

- [ ] 2.3 Extend undo/redo system in GridViewModel
  - Update `saveSnapshot()` to capture entire `elements` array state
  - Update `undo()` and `redo()` to restore `elements` array
  - Test that snapshots are created on: add element, delete element, edit text, transform element

- [ ] 2.4 Update auto-save persistence in GridViewModel
  - Modify `GridAutoSaveConfig` struct (lines 615-620) to include `elements: [CanvasElement]`
  - Remove old `images: [SavedCanvasImage]` field
  - Update `saveToUserDefaults()` to encode CanvasElement array
  - Handle backward compatibility: if old format detected, migrate to new format

- [ ] 2.5 Update restore logic in GridViewModel
  - Modify `restoreFromUserDefaults()` to decode CanvasElement array
  - For text/sticker elements: recreate directly from saved data (lightweight)
  - For image elements: load proxy from `/Caches/autosave_images/{uuid}.jpg`
  - Add migration path: if loading old format, convert CanvasImage → CanvasElement.image

## 3. Text Editing UI

- [ ] 3.1 Create `InstaBorderApp/Views/Components/TextEditorView.swift`
  - SwiftUI sheet view with `@Binding var textElement: TextElement?`
  - TextField for text input (multi-line support with TextEditor)
  - Live preview of text with current formatting below input
  - "Done" button to confirm and dismiss sheet

- [ ] 3.2 Add font picker with common system fonts
  - Use Picker with ForEach over available fonts
  - Fonts: "SF Pro Text", "Helvetica Neue", "Georgia", "Courier New", "Times New Roman", "Arial"
  - Display font name in its own font style in picker

- [ ] 3.3 Add font size slider with real-time preview
  - Slider range: 12pt to 72pt, step 1pt
  - Display current size value next to slider (e.g., "36 pt")
  - Update preview text size in real-time as slider moves

- [ ] 3.4 Add text color picker
  - Reuse existing `ColorPickerButton` from GridEditingView
  - Default color: black
  - Show color swatch next to "Color" label

- [ ] 3.5 Add text alignment buttons
  - HStack with 3 buttons: Left, Center, Right
  - Use SF Symbols: "text.alignleft", "text.aligncenter", "text.alignright"
  - Highlight selected alignment option
  - Note: Alignment affects multi-line text only

- [ ] 3.6 Add background options with picker
  - Segmented picker: "None", "Solid", "Semi-transparent"
  - If Solid/Semi-transparent selected, show background color picker
  - Solid = opacity 1.0, Semi-transparent = opacity 0.5
  - Show preview with background in real-time

- [ ] 3.7 Add "Add Text" button to `GridEditingView.swift` toolbar
  - Add button next to existing "Add Photos" button (use SF Symbol "textformat")
  - On tap: create default TextElement and show TextEditorView sheet
  - Default: text="Double tap to edit", font="SF Pro Text", size=24pt, color=black, position=canvas center

- [ ] 3.8 Enable editing existing text elements
  - In GridCanvasView, add .onTapGesture(count: 2) to text elements
  - On double-tap: set selectedElement and show TextEditorView sheet with current values
  - Save changes on "Done", discard on sheet dismiss without changes

## 4. Sticker Picker UI

- [ ] 4.1 Create `InstaBorderApp/Views/Components/StickerPickerView.swift`
  - Sheet view with TabView: "Emoji" tab and "Icons" tab
  - Callback: `var onSelect: (StickerElement) -> Void`
  - Dismiss sheet automatically after selection

- [ ] 4.2 Integrate existing EmojiPickerView as Emoji tab
  - Reference: `InstaBorderApp/Views/Components/EmojiPickerView.swift`
  - Reuse existing 8 categories and 20 emoji per category
  - On emoji selection: create StickerElement(type: .emoji, content: emoji) and call onSelect

- [ ] 4.3 Create `IconPickerView.swift` for SF Symbols
  - Create categories dictionary mapping category names to SF Symbol arrays
  - Categories and symbols:
    - "Arrows": ["arrow.up", "arrow.down", "arrow.left", "arrow.right", "arrow.up.circle.fill", etc.]
    - "Shapes": ["circle.fill", "square.fill", "triangle.fill", "heart.fill", "star.fill", etc.]
    - "Communication": ["message.fill", "phone.fill", "envelope.fill", "paperplane.fill", etc.]
    - "Weather": ["sun.max.fill", "cloud.fill", "cloud.rain.fill", "moon.stars.fill", etc.]
    - "Nature": ["leaf.fill", "flame.fill", "drop.fill", "snowflake", etc.]
    - "Objects": ["lightbulb.fill", "camera.fill", "music.note", "gift.fill", etc.]
  - Display as scrollable category sections with LazyVGrid (4 columns)
  - Each icon shown at 32pt size with .fill variant where available

- [ ] 4.4 Add search functionality for SF Symbols
  - TextField at top of Icons tab with search icon
  - Filter icons across all categories by name match
  - Show filtered results in single grid (no categories when searching)
  - Clear search on category selection

- [ ] 4.5 Add "Add Sticker" button to `GridEditingView.swift` toolbar
  - Add button next to "Add Text" button (use SF Symbol "face.smiling")
  - On tap: show StickerPickerView sheet
  - Position new sticker at canvas center with default size 64pt

- [ ] 4.6 Handle sticker selection and placement
  - In StickerPickerView onSelect callback: create StickerElement
  - Call GridViewModel.addStickerElement(type:content:at:)
  - Dismiss sheet after selection
  - Add new sticker to canvas at center position

## 5. Canvas Rendering

- [ ] 5.1 Update `GridCanvasView.swift` to render all element types
  - Replace ForEach over `viewModel.images` with ForEach over `viewModel.elements`
  - Use switch statement on element type to render appropriate view
  - Case .image: render existing SingleImageView (reuse current implementation)
  - Case .text: render new TextElementView component
  - Case .sticker: render new StickerElementView component

- [ ] 5.2 Create `InstaBorderApp/Views/Components/TextElementView.swift`
  - Accept `@Binding var element: TextElement` and gesture bindings
  - Render Text view with textElement.text, font, fontSize, color
  - If backgroundColor exists, add background rectangle with specified opacity
  - Apply multilineTextAlignment based on textElement.alignment
  - Make text fixed width for alignment to work correctly
  - Apply .rotationEffect() and .scaleEffect() transforms

- [ ] 5.3 Create `InstaBorderApp/Views/Components/StickerElementView.swift`
  - Accept `@Binding var element: StickerElement` and gesture bindings
  - For type .emoji: render Text view with emoji character at specified size
  - For type .sfSymbol: render Image(systemName: content) with .foregroundColor(color)
  - Apply .rotationEffect() and .scaleEffect() transforms
  - Ensure hit testing works correctly for gestures

- [ ] 5.4 Ensure uniform transform application across element types
  - All elements positioned via .position(element.position)
  - All elements scaled via .scaleEffect(element.scale)
  - All elements rotated via .rotationEffect(element.rotation)
  - Transform order: scale → rotate → position (consistent with SingleImageView)

- [ ] 5.5 Implement Z-order rendering
  - Elements render in array order: viewModel.elements[0] (back) to elements[n-1] (front)
  - Use .zIndex(Double(index)) to ensure correct layering even with gestures
  - When element is being dragged, temporarily increase its zIndex to appear on top

- [ ] 5.6 Add Z-order controls to element selection overlay
  - When element selected (long-press), show action buttons including:
    - "Bring to Front" button (SF Symbol: "square.3.layers.3d.top.filled")
    - "Send to Back" button (SF Symbol: "square.3.layers.3d.bottom.filled")
  - On "Bring to Front": move element to end of array (viewModel.elements.append)
  - On "Send to Back": move element to start of array (viewModel.elements.insert(at: 0))
  - Trigger undo snapshot before Z-order change

## 6. Gesture Interactions

- [ ] 6.1 Add unified drag gesture handling for all element types
  - Extract existing DragGesture logic from SingleImageView
  - Create shared gesture handler in GridCanvasView
  - On drag: update element.position with translation
  - Apply smart snapping to canvas edges (reuse existing snapPosition logic)
  - Trigger haptic feedback on snap

- [ ] 6.2 Add unified pinch-zoom gesture for text and sticker elements
  - Use MagnificationGesture() similar to image handling
  - On pinch: update element.scale (constrain to 0.3× - 4.0× range)
  - For text: scale uniformly (both width and height)
  - For stickers: scale uniformly maintaining aspect ratio

- [ ] 6.3 Add unified rotation gesture for text and sticker elements
  - Use RotationGesture() similar to image handling
  - On rotation: update element.rotation
  - Apply smart snapping to 0°, 90°, 180°, 270° (within 5° threshold)
  - Trigger haptic feedback on rotation snap

- [ ] 6.4 Add simultaneous gesture support
  - Use .simultaneously(with:) to allow drag + pinch + rotate at same time
  - Match behavior of existing SingleImageView gestures
  - Ensure gestures don't conflict with canvas pan/zoom

- [ ] 6.5 Add long-press selection for text and sticker elements
  - LongPressGesture (0.5 second duration)
  - On long-press: set @State var selectedElementId: UUID?
  - Show selection overlay with action buttons centered on element
  - Deselect on tap outside element or on another element

- [ ] 6.6 Create element action overlay view
  - Show when selectedElementId is not nil
  - Display buttons in HStack above selected element:
    - Text: "Edit" (textformat.abc), "Delete" (trash), "Bring to Front", "Send to Back"
    - Sticker: "Delete" (trash), "Bring to Front", "Send to Back"
  - Button style: small, rounded, white background with shadow
  - Position overlay centered above element with 20pt offset

- [ ] 6.7 Test gesture interactions don't interfere
  - Dragging one element doesn't affect others
  - Canvas zoom/pan doesn't activate when gesturing on elements
  - Multiple rapid gestures on same element work smoothly
  - Gestures work correctly on rotated elements

## 7. High-Resolution Export

- [ ] 7.1 Update `GridViewModel.swift` exportGrid() method to handle all element types
  - Current export logic processes images only (lines ~450-550)
  - Extend to iterate through `elements` array instead of `images` array
  - For each tile, determine which elements intersect tile bounds
  - Render elements in Z-order (array order) to maintain layering

- [ ] 7.2 Create helper method `renderTextElement(on context: CGContext, element: TextElement, in bounds: CGRect, scale: CGFloat)`
  - Calculate text position in tile coordinates with scale factor
  - Create NSAttributedString with font, size, color, alignment
  - If background exists, draw background rectangle first with opacity
  - Apply scale transform: fontSize *= element.scale * scale
  - Apply rotation transform around text center point
  - Use CoreText or UIGraphicsImageRenderer to draw text on context
  - Handle multi-line text with proper line breaks and alignment

- [ ] 7.3 Create helper method `renderStickerElement(on context: CGContext, element: StickerElement, in bounds: CGRect, scale: CGFloat)`
  - Calculate sticker position in tile coordinates with scale factor
  - Apply sticker base size * element.scale * scale for final size
  - For emoji: render using NSAttributedString with large font size (prevents pixelation)
  - For SF Symbols: use UIImage(systemName:, withConfiguration:) with correct size and weight
  - Apply tint color for SF Symbols using element.color
  - Apply rotation transform around sticker center
  - Draw using context.draw() or UIGraphicsImageRenderer

- [ ] 7.4 Update tile rendering loop to process elements by type
  - First pass: render all image elements (existing logic)
  - Second pass: render all sticker elements at correct Z-positions
  - Third pass: render all text elements at correct Z-positions
  - Alternatively: single pass rendering elements in array order for correct layering
  - Use autoreleasepool around each tile to prevent memory issues

- [ ] 7.5 Test export scale calculations
  - Canvas size: typically 1080px width (Instagram standard)
  - Tile size: cellWidth × cellHeight at 4:5 aspect ratio
  - Scale factor: tileSize / canvasSize
  - Element positions: multiply by scale factor
  - Font sizes: multiply by element.scale * exportScale
  - Sticker sizes: multiply by element.scale * exportScale

- [ ] 7.6 Handle elements spanning multiple tiles
  - Text element may span 2+ tiles if large or positioned at boundary
  - Each tile renders its portion of the text/sticker
  - Ensure alignment is pixel-perfect at tile boundaries
  - Test with text rotated at various angles spanning tiles

- [ ] 7.7 Test exported tile quality
  - Verify text is crisp and readable at full resolution (not blurry)
  - Verify SF Symbols render at high quality (use .font(.system(size:)) with weight)
  - Verify emoji render at high quality (use large font size, not image scaling)
  - Check that text backgrounds have correct opacity and positioning
  - Verify element layering matches canvas preview

## 8. Localization

- [ ] 8.1 Add English strings to `InstaBorderApp/Resources/en.lproj/Localizable.strings`
  ```
  // Text Editor
  "Add Text" = "Add Text";
  "Edit Text" = "Edit Text";
  "Font" = "Font";
  "Size" = "Size";
  "Color" = "Color";
  "Alignment" = "Alignment";
  "Background" = "Background";
  "None" = "None";
  "Solid" = "Solid";
  "Semi-transparent" = "Semi-transparent";
  "Done" = "Done";
  "Double tap to edit" = "Double tap to edit";

  // Sticker Picker
  "Add Sticker" = "Add Sticker";
  "Emoji" = "Emoji";
  "Icons" = "Icons";
  "Search Icons" = "Search Icons";
  "Arrows" = "Arrows";
  "Shapes" = "Shapes";
  "Communication" = "Communication";
  "Weather" = "Weather";
  "Nature" = "Nature";
  "Objects" = "Objects";

  // Element Actions
  "Edit" = "Edit";
  "Delete" = "Delete";
  "Bring to Front" = "Bring to Front";
  "Send to Back" = "Send to Back";
  ```

- [ ] 8.2 Add Traditional Chinese translations to `InstaBorderApp/Resources/zh-Hant.lproj/Localizable.strings`
  ```
  // Text Editor
  "Add Text" = "新增文字";
  "Edit Text" = "編輯文字";
  "Font" = "字型";
  "Size" = "大小";
  "Color" = "顏色";
  "Alignment" = "對齊";
  "Background" = "背景";
  "None" = "無";
  "Solid" = "實心";
  "Semi-transparent" = "半透明";
  "Done" = "完成";
  "Double tap to edit" = "點兩下以編輯";

  // Sticker Picker
  "Add Sticker" = "新增貼紙";
  "Emoji" = "表情符號";
  "Icons" = "圖示";
  "Search Icons" = "搜尋圖示";
  "Arrows" = "箭頭";
  "Shapes" = "形狀";
  "Communication" = "通訊";
  "Weather" = "天氣";
  "Nature" = "自然";
  "Objects" = "物件";

  // Element Actions
  "Edit" = "編輯";
  "Delete" = "刪除";
  "Bring to Front" = "移到最上層";
  "Send to Back" = "移到最下層";
  ```

- [ ] 8.3 Use NSLocalizedString() in all UI code
  - Replace hardcoded strings with NSLocalizedString("key", comment: "")
  - Test app in English: Settings → Language → English
  - Test app in Chinese: Settings → Language → 繁體中文
  - Verify all new UI displays correctly in both languages

## 9. Testing & Polish

- [ ] 9.1 Test text element lifecycle
  - Create new text element → verify appears at canvas center
  - Edit text content → verify updates in real-time
  - Change font, size, color → verify preview updates correctly
  - Add background → verify renders behind text at correct opacity
  - Move, scale, rotate text → verify transforms work smoothly
  - Delete text → verify removed from canvas and undo stack updated

- [ ] 9.2 Test sticker element lifecycle
  - Open sticker picker → verify tabs and categories load correctly
  - Select emoji → verify appears at canvas center
  - Select SF Symbol → verify renders with default color
  - Move, scale, rotate sticker → verify transforms work smoothly
  - Delete sticker → verify removed from canvas

- [ ] 9.3 Test complex compositions
  - Create canvas with 3 images, 2 text elements, 3 stickers
  - Overlap elements → verify Z-order correct
  - Use "Bring to Front" / "Send to Back" → verify layering changes
  - Export grid → verify all elements render in correct order and position

- [ ] 9.4 Test undo/redo system
  - Perform sequence: add text → edit text → add sticker → delete image
  - Undo 4 times → verify each step reverts correctly
  - Redo 4 times → verify each step reapplies correctly
  - Verify undo stack limit (20 levels) still works

- [ ] 9.5 Test persistence and auto-save
  - Create canvas with text and stickers
  - Wait 5 seconds for auto-save
  - Force close app (swipe up from app switcher)
  - Reopen app and navigate to grid mode
  - Verify restore prompt appears with correct preview
  - Restore session → verify all elements recreated exactly

- [ ] 9.6 Test high-resolution export quality
  - Create 2×2 grid with text and stickers
  - Export to Photos
  - Open exported tiles in Photos app
  - Zoom in on text → verify crisp, not pixelated
  - Zoom in on stickers → verify high quality rendering
  - Verify tiles align perfectly when viewed in Instagram grid

- [ ] 9.7 Test performance and memory
  - Add 20 text elements to canvas
  - Add 20 sticker elements to canvas
  - Check memory usage in Xcode Instruments (should be < 100MB for UI elements)
  - Test smooth scrolling and gesture performance
  - Export large grid (4×4) with many elements → verify completes without crash

- [ ] 9.8 Test edge cases
  - Empty text element → verify handles gracefully
  - Very long text (500 characters) → verify doesn't crash, allows scrolling in editor
  - Text with only whitespace → verify visible on canvas
  - Text rotated 45° spanning multiple tiles → verify renders correctly in export
  - SF Symbol that doesn't exist → verify fallback to question mark symbol

- [ ] 9.9 Test localization in both languages
  - Switch device to English → verify all UI strings correct
  - Switch device to Traditional Chinese → verify all UI strings correct
  - Test Chinese characters in text elements → verify render correctly
  - Test emoji in both language settings → verify render correctly

- [ ] 9.10 Test on multiple device sizes
  - iPhone SE (small screen) → verify UI not cramped, buttons accessible
  - iPhone 15 Pro (standard) → verify layout optimal
  - iPhone 15 Pro Max (large) → verify uses space well
  - Test in portrait orientation (app is portrait-only)

## 10. Documentation & Cleanup

- [ ] 10.1 Add documentation comments to new model files
  - `CanvasElement.swift`: Document each case and its purpose
  - `TextElement`: Document each property and valid ranges
  - `StickerElement`: Document emoji vs SF Symbol handling
  - Add usage examples in comments

- [ ] 10.2 Add documentation to new view files
  - `TextEditorView.swift`: Document bindings and behavior
  - `StickerPickerView.swift`: Document callback pattern
  - `TextElementView.swift`: Document rendering approach
  - `StickerElementView.swift`: Document type handling

- [ ] 10.3 Update CLAUDE.md if architectural patterns changed
  - Document CanvasElement model if it's a significant addition
  - Update architecture section if MVVM pattern usage changed
  - Note any new memory management considerations

- [ ] 10.4 Clean up any debug code or commented-out code
  - Remove any print() statements added during development
  - Remove commented-out experimental code
  - Ensure no TODO or FIXME comments remain
  - Run SwiftLint if available to check code style
