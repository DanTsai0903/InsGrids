## MODIFIED Requirements

### Requirement: Sticker Element Placement
The system SHALL allow users to place SF Symbol icons and custom stickers as sticker elements on the canvas.

**Note**: Emoji functionality has been removed from stickers. Users can add emoji via the text tool instead.

#### Scenario: Open sticker picker
- **WHEN** user taps "Add Sticker" button in toolbar
- **THEN** the system displays sticker picker sheet with tabs: Icon, Sticker

#### Scenario: Place SF Symbol icon
- **WHEN** user selects "heart.fill" icon from Icon tab
- **THEN** the system places icon sticker at canvas center with default color

#### Scenario: Browse icon categories
- **WHEN** user opens Icon tab in sticker picker
- **THEN** the system displays SF Symbol categories: Arrows, Shapes, Communication, Weather, Nature, Objects

#### Scenario: Search for specific icon
- **WHEN** user types "star" in icon search field
- **THEN** the system displays all SF Symbols matching "star" (star.fill, star.circle, etc.)

#### Scenario: Custom sticker tab placeholder
- **WHEN** user opens Sticker tab in sticker picker
- **THEN** the system displays placeholder message "Custom stickers coming soon" with category-based UI structure

#### Scenario: Multiple stickers on canvas
- **WHEN** user adds 5 different stickers (mix of icons and custom stickers) to canvas
- **THEN** each sticker maintains independent position, scale, rotation, and appearance

---

### Requirement: Custom Sticker Category Architecture
The system SHALL provide a category-based architecture for organizing custom stickers, similar to SF Symbol organization.

#### Scenario: Custom sticker categories structure
- **WHEN** developer adds custom stickers to the app
- **THEN** stickers are organized into categories (e.g., Emotions, Animals, Objects)

#### Scenario: Custom sticker category browsing
- **WHEN** user opens Sticker tab with custom stickers available
- **THEN** the system displays stickers grouped by category with category headers

#### Scenario: Search custom stickers
- **WHEN** user types search query in Sticker tab search field
- **THEN** the system filters custom stickers across all categories matching the query

#### Scenario: Place custom sticker
- **WHEN** user selects a custom sticker from Sticker tab
- **THEN** the system places custom sticker at canvas center as image-based sticker element

---

### Requirement: Sticker Element Persistence
The system SHALL save and restore sticker elements (SF Symbols and custom stickers) in auto-save sessions and grid presets.

**Note**: Backward compatibility maintained for old emoji stickers (read-only).

#### Scenario: Auto-save includes icon and custom stickers
- **WHEN** user adds SF Symbol "heart.fill" and custom sticker to canvas
- **THEN** auto-save serializes sticker type (sfSymbol/customSticker), content, color, position, scale, rotation to disk

#### Scenario: Restore session with sticker elements
- **WHEN** user reopens app and restores previous session containing stickers
- **THEN** the system recreates sticker elements with exact type, content, color, position, scale, rotation

#### Scenario: Backward compatibility with emoji stickers
- **WHEN** user opens grid saved with old emoji stickers
- **THEN** the system renders emoji stickers correctly (read-only, cannot create new ones)

#### Scenario: Grid preset saves stickers
- **WHEN** user saves current grid as preset containing sticker elements
- **THEN** preset serializes all sticker data with transforms

#### Scenario: Load grid preset with stickers
- **WHEN** user loads grid preset containing stickers
- **THEN** the system recreates complete composition with stickers at saved positions

---

### Requirement: Sticker Element High-Resolution Export
The system SHALL render sticker elements (SF Symbols, custom stickers, and legacy emoji) at appropriate resolution during tile export.

#### Scenario: Export icon sticker in tile
- **WHEN** tile export encounters SF Symbol sticker within tile bounds
- **THEN** the system renders icon at tile resolution maintaining aspect ratio and quality

#### Scenario: Export custom sticker in tile
- **WHEN** tile export encounters custom sticker element within tile bounds
- **THEN** the system renders custom sticker image at tile resolution maintaining quality

#### Scenario: Sticker spans multiple tiles
- **WHEN** large sticker element spans 2 tiles
- **THEN** each tile renders its portion of sticker seamlessly aligned at tile boundaries

#### Scenario: Sticker Z-order preserved in export
- **WHEN** canvas has image with sticker overlay
- **THEN** tile export renders layers in correct order maintaining sticker position in element array

#### Scenario: SF Symbol color exported correctly
- **WHEN** user changes SF Symbol sticker color to blue
- **THEN** tile export renders icon in specified blue color

#### Scenario: Legacy emoji rendered at high resolution
- **WHEN** tile export renders legacy emoji sticker from old grid
- **THEN** the system uses high-resolution emoji rendering (NSAttributedString with large font size) to prevent pixelation

---

### Requirement: Sticker Element Localization
The system SHALL provide English and Traditional Chinese translations for all sticker element UI with updated terminology.

#### Scenario: Sticker picker UI in English
- **WHEN** device language is English
- **THEN** sticker picker displays: "Add Sticker", "Icon", "Sticker", "Search Stickers"

#### Scenario: Sticker picker UI in Chinese
- **WHEN** device language is Traditional Chinese (zh-Hant)
- **THEN** sticker picker displays: "新增貼紙", "圖示", "貼圖", "搜尋貼紙"

#### Scenario: Icon tab label in English
- **WHEN** device language is English and user views sticker picker
- **THEN** first tab displays "Icon" (SF Symbols)

#### Scenario: Icon tab label in Chinese
- **WHEN** device language is Traditional Chinese and user views sticker picker
- **THEN** first tab displays "圖示" (SF Symbols)

#### Scenario: Sticker tab label in English
- **WHEN** device language is English and user views sticker picker
- **THEN** second tab displays "Sticker" (custom stickers)

#### Scenario: Sticker tab label in Chinese
- **WHEN** device language is Traditional Chinese and user views sticker picker
- **THEN** second tab displays "貼圖" (custom stickers)

#### Scenario: Placeholder message in English
- **WHEN** device language is English and Sticker tab is empty
- **THEN** displays "Custom stickers coming soon"

#### Scenario: Placeholder message in Chinese
- **WHEN** device language is Traditional Chinese and Sticker tab is empty
- **THEN** displays "個性化貼圖即將推出"

---

## REMOVED Requirements

### Requirement: Emoji Sticker Placement
**Reason**: Emoji functionality is redundant with text tool, which already supports emoji input.

**Migration**: Users can add emoji via the text tool. Existing emoji stickers in saved grids remain visible (backward compatible read-only).

#### Scenario: Place emoji sticker
- **REMOVED**: Users cannot place emoji via sticker picker anymore

#### Scenario: Emoji picker displays categories
- **REMOVED**: Emoji tab no longer exists in sticker picker

---

## ADDED Requirements

### Requirement: Custom Sticker Data Model
The system SHALL provide a data model for managing custom sticker categories and sticker assets.

#### Scenario: CustomStickerCategory structure
- **WHEN** system loads custom stickers
- **THEN** each category contains: id (UUID), name (String), localizedKey (String), stickers (array of asset names)

#### Scenario: Empty categories initially
- **WHEN** app first implements custom sticker architecture
- **THEN** `CustomStickerCategory.allCategories` returns empty array or placeholder category

#### Scenario: Custom sticker asset identification
- **WHEN** custom sticker is created
- **THEN** sticker content field stores asset name (e.g., "happy_face" from Assets.xcassets)

#### Scenario: Custom sticker type distinction
- **WHEN** system saves custom sticker
- **THEN** StickerElement type is `.customSticker` (distinct from `.sfSymbol`)

#### Scenario: Custom sticker rendering
- **WHEN** system renders custom sticker on canvas
- **THEN** loads image from Assets.xcassets using asset name in content field
