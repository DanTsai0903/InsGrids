# SPEC: Layout Core

## ADDED Requirements

### Requirement: Shape Support
The system MUST support arbitrary Polygon photo slots, defined by a series of points.
#### Scenario:
Given I select a "complex" template with non-rectangular shapes,
Then I see photo slots matching those shapes.
When I adjust the "Radius",
Then the corners of the polygons get rounded.

### Requirement: Template Selection
The system MUST allow the user to select a template from a predefined list.
#### Scenario:
Given I am on the Layout Start Screen,
When I view the list,
Then I see templates grouped by photo count (or mixed).
When I tap a template,
Then I am prompted to select the corresponding number of photos.

### Requirement: Photo Manipulation
Each photo in the layout loop MUST be capable of being panned and zoomed.
#### Scenario:
Given I am in the Layout Editor,
When I pinch a photo slot,
Then the photo zooms within the slot bounds.
When I drag a photo slot,
Then the photo pans within the slot bounds.

### Requirement: Border Adjustments
The user MUST be able to adjust outer border, inner spacing (gap between photos), and corner radius.
- **Requirement**: Inner spacing MUST be applied such that all photo slots remain visually balanced (lose equal area) and all gaps between photos are of equal width.
- **Scenario**: When adjusting inner spacing in a 3-photo layout, the middle photo MUST NOT shrink more than the top/bottom photos, and both gaps MUST be equal.
- **Scenario**: When corner radius is increased, the photo corners MUST round significantly.
- **Scenario**: When outer border is increased, the entire grid content shrinks to fit within the border.

### Requirement: Canvas Ratio
The user MUST be able to change the overall aspect ratio.
#### Scenario:
Given I am in the Layout Editor,
When I change ratio to 1:1,
Then the canvas becomes square, and slots resize proportionally.
