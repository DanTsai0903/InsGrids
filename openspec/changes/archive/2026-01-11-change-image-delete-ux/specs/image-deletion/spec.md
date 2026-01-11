# Image Deletion Capability

## REMOVED Requirements

### Requirement: Drag-to-Trash Deletion
The app previously allowed users to delete images by dragging them to a trash zone at the bottom of the screen.

#### Scenario: User drags image to trash zone
**Given** the user is editing a canvas with at least one image  
**When** the user drags an image to the bottom trash zone  
**Then** the image is deleted (NO LONGER SUPPORTED)

---

## ADDED Requirements

### Requirement: Image Selection
The app MUST allow users to select an image by tapping on it.

#### Scenario: User taps on an image to select it
**Given** the user is editing a canvas with at least one image  
**When** the user taps on an image  
**Then** the image becomes selected with a visible indicator  
**And** the bottom toolbar shows a delete button

#### Scenario: User taps empty area to deselect
**Given** the user has selected an image  
**When** the user taps on an empty area of the canvas  
**Then** the image is deselected  
**And** the delete button is hidden

### Requirement: Toolbar Delete Button
The app MUST show a delete button in the bottom toolbar when an image is selected.

#### Scenario: User deletes selected image
**Given** the user has selected an image  
**When** the user taps the delete button  
**Then** the selected image is removed from the canvas  
**And** haptic feedback is triggered  
**And** no image is selected after deletion

#### Scenario: Delete button visibility
**Given** the user is editing a canvas  
**When** no image is selected  
**Then** the delete button is not visible in the toolbar

### Requirement: Selection Visual Feedback
The app MUST provide clear visual feedback when an image is selected.

#### Scenario: Selected image has visual indicator
**Given** an image is selected on the canvas  
**Then** the image displays a selection border or highlight  
**And** the indicator remains visible while the image is selected
