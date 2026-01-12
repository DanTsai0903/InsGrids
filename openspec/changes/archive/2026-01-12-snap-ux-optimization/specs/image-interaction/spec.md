## ADDED Requirements
### Requirement: Rotation Snapping
The system SHALL provide magnetic snapping when an image is rotated close to cardinal angles.

#### Scenario: Snap to cardinal angles
- **WHEN** the user rotates an image
- **AND** the rotation angle is within 5 degrees of 0, 90, 180, or 270 degrees
- **THEN** the image rotation snaps to the exact cardinal angle
- **AND** a haptic feedback is triggered

### Requirement: Border Alignment Snapping
The system SHALL snap image edges to canvas boundaries when they are parallel and in close proximity.

#### Scenario: Snap to canvas edge
- **WHEN** the user drags an image near a canvas edge (e.g., within 10 points)
- **AND** the image edge is parallel to the canvas edge (within 1 degree tolerance, i.e., rotation is snapped to 0, 90, 180, or 270)
- **THEN** the image position adjusts so the edges align perfectly
- **AND** a haptic feedback is triggered
