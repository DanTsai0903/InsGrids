# UI Theming

Defines the visual theming system for InsGrids, including color schemes, material effects, and button styles aligned with iOS 26 Liquid Glass design language.

## ADDED Requirements

### Requirement: Semantic Color System

The app SHALL use semantic system colors instead of hardcoded color values for all background and surface elements.

#### Scenario: Main view background uses system color
- **WHEN** the app launches
- **THEN** the main view background uses `Color(.systemBackground)` or equivalent semantic color
- **AND** the color adapts to the system appearance setting

#### Scenario: Dark mode preference is maintained
- **WHEN** the app is configured with `.preferredColorScheme(.dark)`
- **THEN** all views display in dark appearance regardless of system setting
- **AND** semantic colors resolve to their dark mode variants

### Requirement: Material Effects

The app SHALL use SwiftUI Material effects for translucent overlays and sheet backgrounds to integrate with iOS 26 Liquid Glass aesthetic.

#### Scenario: Sheet presentation uses material background
- **WHEN** a sheet is presented (color picker, dimension picker, sticker picker, etc.)
- **THEN** the sheet background uses `.ultraThinMaterial` or `.regularMaterial`
- **AND** content behind the sheet is visible with blur effect

#### Scenario: Toolbar uses material background
- **WHEN** a toolbar is displayed in an editing view
- **THEN** the toolbar background uses appropriate material effect
- **AND** the material adapts to content scrolling beneath it

#### Scenario: Processing overlay uses material
- **WHEN** a processing indicator overlay is shown
- **THEN** the overlay uses `.ultraThinMaterial` instead of solid opacity color
- **AND** the underlying content remains partially visible

### Requirement: Glass Button Style

The app SHALL provide a consistent button style that incorporates glass/material effects while maintaining brand identity.

#### Scenario: Primary action button styling
- **WHEN** a primary action button is displayed (e.g., "Select Photos", "Export")
- **THEN** the button uses a glass-effect background with appropriate material
- **AND** the button has a capsule or rounded rectangle shape
- **AND** text is clearly legible against the material background

#### Scenario: Secondary action button styling
- **WHEN** a secondary action button is displayed (e.g., "Freeform Grid", "Layout")
- **THEN** the button uses a lighter material effect than primary buttons
- **AND** the button has a visible border or outline
- **AND** the styling clearly differentiates it from primary buttons

### Requirement: Multi-Layer App Icon

The app icon SHALL be structured as a multi-layer asset compatible with iOS 26 Icon Composer for dynamic visual effects.

#### Scenario: App icon displays on home screen
- **WHEN** the app icon is displayed on the iOS 26 home screen
- **THEN** the icon supports parallax/depth effects when device is tilted
- **AND** the icon layers (background, midground, foreground) move independently

#### Scenario: App icon displays in App Library
- **WHEN** the app icon is displayed in the App Library or Spotlight
- **THEN** the icon renders correctly at all required sizes
- **AND** dynamic effects are visible where supported

### Requirement: Accessibility Compliance

The themed UI SHALL maintain accessibility standards including sufficient contrast ratios and Dynamic Type support.

#### Scenario: Text remains legible on material backgrounds
- **WHEN** text is displayed over a material background
- **THEN** the text color provides sufficient contrast (WCAG AA minimum)
- **AND** text scales appropriately with Dynamic Type settings

#### Scenario: High contrast mode is respected
- **WHEN** the user has enabled Increase Contrast accessibility setting
- **THEN** material effects reduce transparency
- **AND** borders and separators become more prominent
