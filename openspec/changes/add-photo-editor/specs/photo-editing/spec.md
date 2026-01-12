# Capability: Photo Editing

## ADDED Requirements

#### Scenario: User adjusts photo brightness
Given a photo is selected for editing
When the user moves the brightness slider
Then the photo preview should update in real-time
And the adjustment should be preserved when the editor is closed

#### Scenario: User applies a filter
Given the filter list is visible
When the user taps on "Mono" filter
Then the photo should appear black and white
And the filter selection should be highlighted

#### Scenario: User saves edits
Given the user has applied adjustments and filters
When the user taps "Done"
Then the editor should close
And the canvas should show the edited version of the photo
But the original photo file should remain unchanged (non-destructive)

#### Scenario: Export with edits
Given a grid contains edited photos
When the user exports the grid
Then the output image should include all applied edits at full resolution
