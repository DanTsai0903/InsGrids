# Text Editor UI Redesign - Design Document

## Architecture

### Component Structure

```
TextEditorView (Redesigned)
├── ZStack
│   ├── Canvas Overlay (Dimmed/Blurred)
│   ├── Text Preview (Live, positioned)
│   ├── Bottom Control Bar
│   │   ├── Font Button
│   │   ├── Color Button
│   │   ├── Alignment Button
│   │   ├── Background Button
│   │   └── Done Button
│   ├── CustomColorPaletteView (Inline above controls)
│   ├── EyedropperOverlayView (Full screen when active)
│   └── Vertical Size Slider (Right Edge)
```

### Layout Strategy

#### 1. Canvas Overlay Mode
- Use `ZStack` with full screen GeometryReader
- Semi-transparent dark overlay for focus
- Text preview positioned at element's canvas location
- Controls float above canvas

#### 2. Control Bar Design
- Fixed position at bottom of screen
- Horizontal stack of icon buttons
- Compact, touch-friendly targets (50x50pt minimum)
- Similar to Instagram's bottom toolbar

#### 3. Custom Color Picker
- Inline horizontal scrollable palette above control bar
- 3 Pages: Basic, Warm, Neutral (Grayscale)
- Page indicators below palette
- Eyedropper button on left side

#### 4. Size Slider
- Vertical slider aligned to right edge
- Height: ~40% of screen
- Positioned middle-right
- Custom slider track for better visibility

## UI Flow

### Opening Editor
1. User taps text tool icon → creates new text at canvas center
2. User taps existing text → opens editor with current text
3. Editor slides up with animation
4. Canvas dims, text element highlighted
5. Keyboard appears for text input

### Editing Flow
1. User types → text updates in real-time on canvas
2. User taps font button → font picker sheet appears
3. User drags size slider → font size adjusts live
4. User taps color button → color palette slides up
   - Horizontal scroll to choose colors
   - Tap eyedropper → enter sampling mode
5. User taps alignment → cycles through L/C/R
6. User taps background → cycles through none/solid/semi and opens color palette

### Color Sampling (Eyedropper)
1. Tap eyedropper icon in palette
2. **UI Transition**:
   - Bottom control bar, top bar, and slider fade out (hidden)
   - Background dimming layer fades out (clear view)
   - Text being edited moves to **Top-Left Corner** (pinned preview)
3. **Active Sampling**:
   - Drag finger on canvas to move sampling pin
   - Pin shows current color magnification
   - **Real-time Update**: Top-left text preview updates color instantly
4. **Completion**:
   - Release finger to confirm selection
   - Controls and dimming fade back in
   - Text returns to original position

> **Technical Note**: The eyedropper requires a snapshot of the underlying canvas to function. This snapshot (`UIImage`) must be passed from the parent view into `TextEditorView` upon initialization or activation.

### Saving/Dismissing
1. User taps "Done" → saves changes, dismisses editor
2. If text is empty → delete text element instead of saving
3. Keyboard dismisses, canvas returns to normal

## Component Details

### Text Preview Layer
```swift
// Positioned text that updates live
Text(text.isEmpty ? "Tap to type" : text)
    .font(fontForCurrentSelection(size: fontSize))
    .foregroundColor(textColor)
    .multilineTextAlignment(alignment)
    .background(backgroundView)
    .position(textPosition) // From original element.position
```

### Control Buttons Specification

| Button | Icon | Action | State Indicator |
|--------|------|--------|----------------|
| Font | "Aa" or textformat | Sheet → FontPickerView | Font name below icon |
| Color | circle.fill | Toggle inline palette (Text) | Highlighting when active |
| Align | text.alignleft/center/right | Cycle alignment | Icon shows current |
| Background | square.fill.text.grid.1x2 | Cycle type / Toggle palette (Bg) | Icon shows current |
| Done | checkmark | Save & dismiss | Always enabled if text not empty |

### Vertical Size Slider
```swift
Slider(value: $fontSize, in: 12...72, step: 1)
    .rotationEffect(.degrees(-90))  // Vertical orientation
    .frame(width: 200, height: 44)  // Rotated dimensions
    .position(x: screenWidth - 40, y: screenHeight / 2)
```

## Interaction Patterns

### Tap-to-Edit Implementation
Update `GridCanvasView` to call `onEditText` on single tap:

```swift
.simultaneousGesture(
    TapGesture(count: 1)
        .onEnded {
            onEditText?(element.id)
        }
)
```

### Auto-Delete on Empty Text
In `saveAndDismiss()`:

```swift
if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    // Don't save, trigger delete instead
    if textElement != nil {
        // Signal parent to delete this element
    }
    dismiss()
} else {
    // Normal save flow
    onSave(element)
    dismiss()
}
```

## Visual Design

### Color Palette
- Background overlay: Black @ 60% opacity
- Control bar background: Dark gray with blur effect
- Button tint: White for inactive, accent color for active
- Slider track: White @ 30%, thumb: White

### Typography
- Control labels: SF Pro, 12pt, Semibold
- Size indicator: SF Pro, 14pt, Bold

### Spacing
- Control bar padding: 16pt horizontal, 12pt vertical
- Button spacing: 20pt between icons
- Slider margin: 20pt from edge

## Reusable Components

### Existing (No Changes)
- `FontPickerView` - Full screen font selector
- `TextElement` - Model structure
- `TextView` - Canvas text rendering
- Font rendering logic in `fontForElement()`

### Modified
- `TextEditorView` - Complete UI restructure
- Text element delete logic - Check for empty text

### New (Minimal)
- Vertical slider wrapper view (if needed for styling)
- Control button component (optional, could be inline)

## Accessibility

- All buttons have accessibility labels
- Slider has value label
- Text input supports VoiceOver
- Sufficient contrast for all controls
- Minimum touch target: 44x44pt

## Animation

- Editor appears: Slide up from bottom (0.3s ease-out)
- Editor dismisses: Slide down (0.25s ease-in)
- Control changes: Instant feedback (no animation)
- Canvas overlay: Fade in/out (0.2s)

## Error Handling

- Empty text → auto-delete (not an error, expected behavior)
- Invalid font fallback → Already handled in `resolvedFontWeight()`
- Color picker cancellation → Maintains previous color

## Testing Considerations

- Verify tap vs drag gesture discrimination
- Test slider responsiveness at various screen sizes
- Validate auto-delete behavior
- Check canvas overlay rendering performance
- Test with different text lengths and sizes
- Verify keyboard doesn't obscure controls
