## ADDED Requirements

### Requirement: Unified Canvas Element Model
The system SHALL support multiple element types (images, text, stickers) through a unified element model with shared transform properties.

#### Scenario: CanvasElement enum supports multiple types
- **WHEN** system manages canvas elements
- **THEN** the system uses `CanvasElement` enum with cases: `.image(ImageElement)`, `.text(TextElement)`, `.sticker(StickerElement)`

#### Scenario: All elements share transform properties
- **WHEN** any element type is manipulated
- **THEN** the element provides: `id`, `position`, `scale`, `rotation` properties

#### Scenario: Element Z-order management
- **WHEN** canvas contains mixed element types (images, text, stickers)
- **THEN** the system renders elements in array order with last element on top (overlapping earlier elements)

#### Scenario: Z-order preserved in auto-save
- **WHEN** user arranges elements with specific layering and app auto-saves
- **THEN** restored session maintains exact element order (Z-order)

#### Scenario: Newly added elements appear on top
- **WHEN** user adds new element (image, text, or sticker) to canvas
- **THEN** the system places element at end of array, rendering on top of existing elements

#### Scenario: Element selection provides Z-order controls
- **WHEN** user selects any canvas element and action overlay displays
- **THEN** overlay includes "Bring to Front" and "Send to Back" buttons for all element types

#### Scenario: Backward compatibility with image-only canvases
- **WHEN** user opens auto-saved session created before text/sticker support
- **THEN** the system migrates `CanvasImage` data to `CanvasElement.image(ImageElement)` format automatically
