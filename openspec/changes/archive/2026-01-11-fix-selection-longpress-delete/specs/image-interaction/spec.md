# Image Interaction Capability

## REMOVED Requirements

### Requirement: Tap to Select
The app previously allowed users to select an image by tapping on it.

#### Scenario: User taps on an image to select it
**Given** the user is editing a canvas with at least one image  
**When** the user taps on an image  
**Then** the image becomes selected with a visible indicator (NO LONGER SUPPORTED)

### Requirement: Toolbar Delete Button
The app previously showed a delete button in the toolbar when an image was selected.

#### Scenario: User deletes selected image via toolbar
**Given** the user has selected an image  
**When** the user taps the delete button in toolbar  
**Then** the selected image is removed (NO LONGER SUPPORTED)

---

## ADDED Requirements

### Requirement: Long-Press Context Menu
The app MUST show a context menu with delete option when user long-presses on an image.

#### Scenario: User long-presses to delete
**Given** the user is editing a canvas with at least one image  
**When** the user long-presses on an image  
**Then** a context menu appears with a "Delete" option  
**And** tapping "Delete" removes the image from the canvas

#### Scenario: Long-press works at any zoom level
**Given** the canvas is zoomed in or out  
**When** the user long-presses on an image  
**Then** the context menu appears correctly
