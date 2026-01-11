# image-interaction Specification

## Purpose
TBD - created by archiving change fix-selection-longpress-delete. Update Purpose after archive.
## Requirements
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

