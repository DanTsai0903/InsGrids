# Spec: Sticker Elements (Expand Emoji Library)

## MODIFIED Requirements

### Requirement: Emoji Picker Library

The emoji picker SHALL provide comprehensive access to all standard iOS emojis organized by category with search capability.

#### Scenario: Complete emoji coverage
- **GIVEN** the user opens the emoji picker in sticker mode
- **WHEN** they browse through all categories
- **THEN** they find ~1,800 emojis across 8 categories matching iOS keyboard organization

#### Scenario: Smileys & People category
- **GIVEN** the user selects the 😀 category
- **WHEN** they scroll through the grid
- **THEN** they see ~500 emojis including:
  - All facial expressions (smiling, laughing, loving, concerned, negative, neutral, silly, etc.)
  - Hand gestures and body parts
  - People with various professions, activities, and attributes
  - Skin tone variants for applicable emojis

#### Scenario: Animals & Nature category
- **GIVEN** the user selects the 🐱 category
- **WHEN** they scroll through the grid
- **THEN** they see ~150 emojis including:
  - Mammals, birds, reptiles, amphibians, fish, and invertebrates
  - Plants, flowers, and trees
  - Weather phenomena and natural elements

#### Scenario: Food & Drink category
- **GIVEN** the user selects the 🍕 category
- **WHEN** they scroll through the grid
- **THEN** they see ~130 emojis including:
  - Fruits and vegetables
  - Prepared foods (meals, snacks, desserts)
  - Beverages (hot, cold, alcoholic)
  - Kitchen utensils

#### Scenario: Activity category
- **GIVEN** the user selects the ⚽ category
- **WHEN** they scroll through the grid
- **THEN** they see ~90 emojis including:
  - Sports and athletic activities
  - Games and hobbies
  - Arts, music, and entertainment
  - Trophy and award symbols

#### Scenario: Travel & Places category
- **GIVEN** the user selects the 🚗 category
- **WHEN** they scroll through the grid
- **THEN** they see ~120 emojis including:
  - Ground transportation
  - Water and air transportation
  - Buildings and architectural structures
  - Geographic and celestial places
  - Maps and navigation symbols

#### Scenario: Objects category
- **GIVEN** the user selects the 💡 category
- **WHEN** they scroll through the grid
- **THEN** they see ~250 emojis including:
  - Technology and computer equipment
  - Household items and furniture
  - Tools and mechanical equipment
  - Clothing and accessories
  - Office and school supplies

#### Scenario: Symbols category
- **GIVEN** the user selects the ❤️ category
- **WHEN** they scroll through the grid
- **THEN** they see ~280 emojis including:
  - Hearts in various styles and colors
  - Geometric shapes and patterns
  - Directional arrows and symbols
  - Warning and informational signs
  - Zodiac, religious, and cultural symbols
  - Musical and audio symbols

#### Scenario: Flags category
- **GIVEN** the user selects the 🏳️ category
- **WHEN** they scroll through the grid
- **THEN** they see ~270 emojis including:
  - National flags in alphabetical order
  - Regional and subdivision flags
  - Special-purpose flags (rainbow, pirate, etc.)

#### Scenario: Category navigation
- **GIVEN** the user is browsing emojis
- **WHEN** they tap a different category icon
- **THEN** the grid instantly updates to show that category's emojis with smooth scrolling

#### Scenario: Emoji selection and placement
- **GIVEN** the user selects any emoji from any category
- **WHEN** they tap on it
- **THEN** a sticker element is created at the canvas center with that emoji
- **AND** the picker remains open for additional selections OR closes based on UX flow

#### Scenario: Performance with large emoji sets
- **GIVEN** the emoji picker contains ~1,800 emojis
- **WHEN** the user scrolls through any category
- **THEN** the grid renders smoothly without lag or memory issues
- **AND** category switching feels instant

#### Scenario: Emoji rendering quality
- **GIVEN** any emoji is selected and placed on canvas
- **WHEN** the user scales it up to 4× or exports the composition
- **THEN** the emoji renders crisply at all sizes using iOS system emoji glyphs

### Requirement: Emoji Search

The emoji picker SHALL provide real-time search to filter emojis across all categories.

#### Scenario: Search bar visibility
- **GIVEN** the emoji picker is open
- **WHEN** the user views the picker
- **THEN** a search bar appears above the category tabs
- **AND** the search field shows placeholder text "Search Emoji"

#### Scenario: Search by keyword
- **GIVEN** the user types "heart" in the search bar
- **WHEN** the search executes
- **THEN** the grid shows all heart-related emojis (❤️, 💛, 💚, 💙, 💜, 🖤, 🤍, 🤎, 💔, ❣️, 💕, etc.)
- **AND** emojis from multiple categories appear in the results

#### Scenario: Search by category name
- **GIVEN** the user types "food" in the search bar
- **WHEN** the search executes
- **THEN** the grid shows all emojis from the Food & Drink category

#### Scenario: Case-insensitive search
- **GIVEN** the user types "SMILE" in the search bar
- **WHEN** the search executes
- **THEN** the results match as if they typed "smile" (case doesn't matter)

#### Scenario: Real-time search filtering
- **GIVEN** the user is typing in the search bar
- **WHEN** each character is entered or deleted
- **THEN** the results update immediately without requiring enter/submit

#### Scenario: Clear search button
- **GIVEN** the user has text in the search bar
- **WHEN** they view the search field
- **THEN** a clear "X" button appears on the right side
- **AND** tapping it clears the search and returns to category view

#### Scenario: No search results
- **GIVEN** the user searches for "xyz123" (nonexistent)
- **WHEN** the search completes
- **THEN** the grid shows empty state with message "No results found"

#### Scenario: Search result selection
- **GIVEN** the user has search results displayed
- **WHEN** they tap an emoji from the search results
- **THEN** the emoji is selected and creates a sticker element
- **AND** the search state is preserved for additional selections

#### Scenario: Exit search mode
- **GIVEN** the user has active search with results
- **WHEN** they clear the search text or tap the clear button
- **THEN** the view returns to category tabs and category grid display

#### Scenario: Search performance
- **GIVEN** the user types rapidly in the search bar
- **WHEN** filtering ~1,800 emojis
- **THEN** results appear within 100ms with no lag or stuttering
