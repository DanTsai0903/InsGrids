# Change: Adapt UI for iOS 26 Liquid Glass Design System

## Why

iOS 26 introduces "Liquid Glass" - the largest UI refresh since iOS 7. Apps that don't adapt will appear outdated and inconsistent with the system aesthetic. The current InsGrids UI uses hardcoded dark backgrounds and custom button styles that won't integrate with the new translucent, material-based design language.

## What Changes

### UI Theming
- **BREAKING**: Replace hardcoded `Color.black` backgrounds with semantic system colors
- Replace `Color.gray.opacity()` overlays with SwiftUI Material effects
- Update button styles to align with iOS 26 visual standards
- Add support for new sheet presentation backgrounds

### App Icon
- **BREAKING**: Create multi-layered app icon using Icon Composer for dynamic effects
- Separate foreground, midground, and background layers

### System Integration
- Adopt new SwiftUI modifiers for Liquid Glass effects where appropriate
- Ensure proper light/dark mode adaptation with semantic colors

## Impact

- **Affected specs**: ui-theming (new capability)
- **Affected code**:
  - `InstaBorderApp/Views/ContentView.swift` - Main screen background and buttons
  - `InstaBorderApp/Views/GridEditingView.swift` - Toolbar and overlays
  - `InstaBorderApp/Views/EditingView.swift` - Editor interface
  - `InstaBorderApp/Views/LayoutEditorView.swift` - Layout editor interface
  - `InstaBorderApp/Views/Components/*.swift` - All sheet and picker components
  - `InstaBorderApp/Resources/Assets.xcassets/AppIcon.appiconset/` - App icon assets

## Dependencies

- Xcode 26 beta or later
- iOS 26 SDK

## Rollback Strategy

If issues arise, semantic colors and materials gracefully degrade on older iOS versions. The app will continue to function with the system's default appearance handling.
