# Text and Sticker Scaling

## MODIFIED Requirements

### Requirement: Element Scale Transformation

The system SHALL allow text and sticker elements to be scaled using pinch-to-zoom gestures with no upper limit and a minimum scale of 0.3×.

#### Scenario: User scales text element to large size
- **GIVEN** a text element is on the canvas
- **WHEN** user performs pinch-to-zoom gesture to enlarge
- **THEN** the text scales proportionally with no upper limit
- **AND** the minimum scale is 0.3×

#### Scenario: User scales sticker element to large size
- **GIVEN** a sticker element (emoji or SF Symbol) is on the canvas
- **WHEN** user performs pinch-to-zoom gesture to enlarge
- **THEN** the sticker scales proportionally with no upper limit
- **AND** the minimum scale is 0.3×

#### Scenario: User tries to scale element too small
- **GIVEN** a text or sticker element is on the canvas
- **WHEN** user pinches to reduce scale below 0.3×
- **THEN** the scale is constrained to 0.3× minimum
- **AND** the element remains visible and interactable
