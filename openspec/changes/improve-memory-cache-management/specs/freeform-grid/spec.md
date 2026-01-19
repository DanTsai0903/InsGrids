## MODIFIED Requirements

### Requirement: Memory Management for Grid Processing
The system SHALL process grid tiles serially with autoreleasepool to prevent memory crashes when generating large grids, and SHALL automatically clean up temporary cache files to prevent storage bloat.

#### Scenario: Serial tile processing
- **WHEN** generating tiles from a 3x3 grid (9 tiles)
- **THEN** the system processes tiles one at a time on a background thread, not in parallel

#### Scenario: Memory cleanup between tiles
- **WHEN** each tile is generated and saved
- **THEN** the system uses autoreleasepool to release memory before processing the next tile

#### Scenario: Respect 12MP limit per tile
- **WHEN** a grid cell would result in a tile larger than 12 megapixels
- **THEN** the system scales down the final tile to respect the 12MP maximum

#### Scenario: Reuse shared PhotoEditorEngine singleton
- **WHEN** applying photo adjustments during tile rendering
- **THEN** the system SHALL use PhotoEditorEngine.shared instead of creating new instances per tile

#### Scenario: Auto-save cache cleanup
- **WHEN** auto-save cleanup runs every 5 seconds
- **THEN** the system SHALL purge orphaned files from both autosave_images AND original_images cache folders

#### Scenario: App lifecycle cache cleanup
- **WHEN** the app transitions to background or inactive state
- **THEN** the system SHALL trigger cache cleanup to remove orphaned temporary files

#### Scenario: Cache size monitoring
- **WHEN** total cache size exceeds 500MB
- **THEN** the system SHALL trigger aggressive cleanup by deleting oldest cached files first

#### Scenario: Cache integrity check on launch
- **WHEN** the app launches
- **THEN** the system SHALL validate cache integrity and remove corrupted or orphaned files
