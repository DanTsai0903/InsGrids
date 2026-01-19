## ADDED Requirements

### Requirement: Sticker Automation CLI
The system SHALL provide a command-line interface to automate the sticker creation workflow.

#### Scenario: Generate and Ingest
- **WHEN** the user runs the agent with a prompt (e.g., "pixel art heart")
- **THEN** it generates multiple variants
- **AND** presents them to the user for selection
- **WHEN** the user selects specific variants
- **THEN** it adds them to the Xcode asset catalog
- **AND** updates the code to include the new stickers in the appropriate category

### Requirement: Batch Processing
The system SHALL support batch generation of multiple stickers from a list of prompts.

#### Scenario: Batch Generation
- **WHEN** the user provides a text file with multiple prompts
- **AND** runs the batch command
- **THEN** the system generates variants for each prompt
- **AND** presents all variants for selection
- **WHEN** the user selects variants to keep
- **THEN** all selected stickers are ingested into the project

### Requirement: Transparent Backgrounds
The system SHALL generate stickers with transparent backgrounds by default.

#### Scenario: Transparent Background Generation
- **WHEN** the user provides any prompt
- **THEN** the system automatically enhances the prompt with transparent background instructions
- **AND** the generated images have transparent backgrounds

### Requirement: AI-Assisted Category Assignment
The system SHALL provide AI-powered category suggestions for generated stickers.

#### Scenario: Category Suggestion
- **WHEN** stickers are generated
- **THEN** the system uses AI to analyze the images
- **AND** suggests appropriate categories
- **AND** allows the user to accept or modify the suggestions before ingestion
