# PROPOSAL: Add Layout Feature

> [!NOTE]
> This feature mimics Instagram Layout app functionality.

## Motivation
Users want to create collages with specific templates, capable of adjusting borders (both outer frame and inner spacing between photos), roundness, and manipulating individual photos. Existing "Freeform Grid" is different; this is a structured template-based layout.

## Detailed Design
We will introduce a `LayoutTemplate` system where templates define normalized frames for image slots.
The flow will be: `LayoutTemplateSelectView` -> `PhotosPicker` -> `LayoutEditorView`.

### Data Models
- **`LayoutTemplate`**: Enum defining styles (e.g. `grid2x2`, `columns3`). Returns `[CGRect]` (normalized).
- **`LayoutConfiguration`**: Struct conforming to `Codable`.
- **`PhotoItem`**: Wrapper for `UIImage` + transform data (scale, offset).

### UI Architecture
- **`LayoutEditorView`**:
    - **Header**: Back, Title, Save.
    - **Canvas**: `GeometryReader` rendering `LayoutSlotView`s based on template.
    - **Controls**:
        - **Template Picker**: Scrollable list of templates with matching slot count.
        - **Sliders**: Border (Outer), Spacing (Inner/Gap), Corner Radius.
        - **Ratio**: Aspect Ratio sheet.
        - **Background**: Color picker.

## Alternatives Considered
- **Dynamic Split**: Allowing users to drag dividers to resize slots. (Out of scope for v1, fixed templates requested).
