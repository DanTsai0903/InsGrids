# Redesign Text Editor UI

## Overview
Redesign the text editing interface to match Instagram's text tools UI pattern, featuring a visible canvas overlay with button-based controls and improved interaction patterns.

## Goals
1. **Visual Consistency**: Match Instagram's modern text editing UI with visible canvas and compact controls
2. **Improved UX**: Replace scroll-based settings with intuitive button controls
3. **Simplified Deletion**: Remove dedicated delete button; users delete by clearing all text
4. **Direct Editing**: Enable tap-to-edit for quick text modifications

## Current State
- Text editor is a full-screen modal with scroll view containing multiple sections
- Settings use segmented controls, sliders, and pickers
- Delete functionality via dedicated button overlay on canvas
- Text editing requires re-opening the text editor sheet

## Proposed Changes

### 1. Text Tool Icon Update
- Replace current text tool icon with "Aa + 文字" style (matching uploaded reference image 1)
- Keep icon simple and recognizable

### 2. Canvas-Overlay Editor
- Transform `TextEditorView` from scroll-based modal to canvas overlay
- Show canvas content behind editor (dimmed/blurred background)
- Position text being edited on the visible canvas
- Real-time preview as user types and adjusts settings

### 3. Button-Based Controls
Convert all settings to compact button controls at bottom of screen:
- **Font**: "Aa" button → opens font picker sheet
- **Color**: Color circle button → slides up inline color palette
- **Alignment**: Icon button (left/center/right) → cycles through options
- **Background**: Icon button → cycles through none/solid/semi-transparent (also opens palette)

### 4. Custom Color Picker & Eyedropper
- **Inline Palette**: Horizontal scrollable list of preset colors (Basic, Warm, Grayscale)
- **Compact UI**: Replaces full-screen sheet picker for faster access
- **Eyedropper**: Tool to sample colors directly from the canvas image
   - Drag-to-pick interaction with magnification pin
   - Auto-applies sampled color on release
   - *Requirement: Parent view must provide canvas snapshot*
   - **Interaction**: Hides editor UI and moves text to top-left corner during sampling for clear view

### 5. Vertical Text Size Slider
- Add vertical slider on right edge of screen
- Range: 12-72pt (matching current implementation)
- Visual indicator showing current size
- Similar to Instagram's implementation

### 6. Simplified Deletion
- Remove delete button from text element overlay
- Auto-delete text element when user clears all text characters
- Cleaner interaction model

### 7. Tap-to-Edit
- Single tap on text element opens editor for modification
- Long press still triggers editor (current behavior)
- Maintains existing gesture handling for move/scale/rotate

## Non-Goals
- No new functionality beyond UI redesign
- Reuse all existing font, color, and text rendering logic
- No changes to text persistence or model structures

## Technical Approach
- Modify `TextEditorView.swift` to use overlay layout instead of ScrollView
- Create `CustomColorPaletteView` for inline color selection
- Create `EyedropperOverlayView` for canvas sampling
- Update `TextElementView` gestures in `GridCanvasView`
- Wire color picker logic to switch between Text/Background modes

## Dependencies
- Existing `TextElement` model
- Existing `FontPickerView`
- Existing text rendering in `TextElementView`
- Existing gesture handling in `GridCanvasView`

## References
- Uploaded image 1: Text tool icon reference ("Aa + 文字")
- Uploaded image 2: Instagram text UI reference (canvas visible, button controls, vertical slider)
