# layout-editor Specification Delta

## ADDED Requirements

### Requirement: Photo Switching Between Slots
The system SHALL allow users to swap photos between two different slots in a layout template through a dedicated switch mode.

#### Scenario: Activate switch mode
- **GIVEN** a slot contains a photo
- **WHEN** the user long-presses on the slot
- **THEN** an action menu appears with Edit, Crop, Delete, and Switch buttons
- **AND** tapping the Switch button activates switch mode

#### Scenario: Visual feedback in switch mode
- **GIVEN** switch mode is active with a source slot selected
- **WHEN** the user views the layout
- **THEN** the source slot displays an orange glow with pulsing animation (0.8s repeat)
- **AND** the source slot scales to 1.02x with spring animation
- **AND** all other slots with photos display a green highlight

#### Scenario: Successful photo swap
- **GIVEN** switch mode is active with slot A as the source
- **WHEN** the user taps on slot B containing a photo
- **THEN** the photos in slot A and B are swapped with 0.3s ease-in-out animation
- **AND** both photos reset to default transforms (scale=1.0, offset=0)
- **AND** success haptic feedback is triggered
- **AND** switch mode exits automatically

#### Scenario: Prevent self-swap
- **GIVEN** switch mode is active with slot A as the source
- **WHEN** the user taps on slot A again
- **THEN** no swap occurs
- **AND** switch mode exits

#### Scenario: Switch mode supports undo
- **GIVEN** a photo swap has been completed
- **WHEN** the user taps the undo button
- **THEN** the photos return to their original slots
- **AND** their previous transforms are restored

### Requirement: Switch Button Appearance
The Switch button MUST be visually distinct and clearly indicate the swapping action.

#### Scenario: Switch button design
- **GIVEN** the action menu is displayed
- **WHEN** the user views the Switch button
- **THEN** the button displays a white circle (70x70 points)
- **AND** shows a blue "arrow.left.arrow.right" icon (28pt bold)
- **AND** has a shadow (black 30% opacity, radius 5, offset y=2)

### Requirement: Haptic Feedback for Switch Actions
The system SHALL provide haptic feedback during switch interactions for tactile confirmation.

#### Scenario: Haptic on switch mode activation
- **GIVEN** the user is viewing the action menu
- **WHEN** the user taps the Switch button
- **THEN** medium impact haptic feedback is triggered

#### Scenario: Haptic on successful swap
- **GIVEN** switch mode is active
- **WHEN** the user completes a photo swap
- **THEN** success notification haptic feedback is triggered
