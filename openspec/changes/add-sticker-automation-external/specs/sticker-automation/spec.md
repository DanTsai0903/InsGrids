# Start of Sticker Automation Spec

## ADDED Requirements

### Requirement: Desktop Folder Import
The system MUST provide a CLI tool `sticker-importer` to import stickers from a directory. The tool MUST accept a directory path and ingest valid stickers found within.

#### Scenario: User runs import on a valid directory
Given a directory `~/Desktop/stickers/CategoryA` containing `sticker1.png`
When the user runs `uv run sticker-importer import ~/Desktop/stickers`
Then a new category `CategoryA` is created in `Assets.xcassets`
And `sticker1.imageset` is created within it
And `CustomStickerCategory.swift` is updated to include `CategoryA`

### Requirement: Category Detection
The system MUST detect categories from folder names. The tool MUST interpret folder names as categories, stripping common ID prefixes.

#### Scenario: Folder has ID prefix
Given a folder named `123456-CuteAnimals`
When it is imported
Then the category name is `CuteAnimals`

#### Scenario: Folder has no prefix
Given a folder named `Landscapes`
When it is imported
Then the category name is `Landscapes`

### Requirement: Duplicate Category Prevention
The system MUST check for existing categories before creating new ones. When a category already exists, stickers MUST be appended to the existing category rather than creating duplicates.

#### Scenario: Category already exists
Given `CustomStickerCategory.swift` already contains a category `Animals`
When the user imports a folder `4567-Animals` with new stickers
Then the system appends the new stickers to the existing `Animals` category
And does not create a duplicate `Animals` category

#### Scenario: New category
Given `CustomStickerCategory.swift` does not contain a category `Flowers`
When the user imports a folder `Flowers`
Then the system creates a new `Flowers` category

### Requirement: AI Labeling
The system MUST provide an option to generate labels for stickers using an AI model.

#### Scenario: User requests AI labeling
Given a sticker image `dog.png`
When the user runs import with `--ai-label`
Then the tool calls the Gemini API to analyze the image
And the resulting keywords are associated with the sticker in `CustomStickerCategory.swift` (or printed to console if model doesn't support labels yet)

### Requirement: Format Priority
The system MUST prioritize vector (SVG) formats over raster (PNG) formats when importing stickers.

#### Scenario: Both SVG and PNG exist
Given a category folder `Shapes` containing both `svg/star.svg` and `png/star.png`
When the user runs import
Then the system imports `star.svg` from the `svg` folder
And ignores the `png` folder for that category

#### Scenario: Only PNG exists
Given a category folder `Photos` containing only `png/pic.png`
When the user runs import
Then the system imports `pic.png` from the `png` folder
