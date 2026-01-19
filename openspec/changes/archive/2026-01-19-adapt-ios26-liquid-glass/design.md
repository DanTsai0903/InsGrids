# Design: iOS 26 Liquid Glass Adaptation

## Context

iOS 26 (WWDC 2025) introduces the "Liquid Glass" design system - the most significant visual overhaul since iOS 7. This affects:
- System UI components (navigation bars, tab bars, sheets)
- Material and translucency effects
- Button and control styling
- App icon requirements (multi-layer for dynamic effects)

InsGrids currently uses a custom dark theme with hardcoded colors that won't integrate with the new system aesthetic.

## Goals / Non-Goals

### Goals
- Adopt iOS 26 Liquid Glass visual language
- Maintain visual consistency with system apps
- Preserve the premium dark aesthetic while using semantic colors
- Support both light and dark appearance modes properly
- Create compliant multi-layer app icon

### Non-Goals
- Complete UI redesign (only adapt existing design to new system)
- Add new features (this is purely visual adaptation)
- Support iOS versions below 26 (already minimum target)

## Decisions

### 1. Background Color Strategy

**Decision**: Replace `Color.black` with `Color(.systemBackground)` and use `.preferredColorScheme(.dark)` to maintain dark appearance.

**Rationale**:
- Semantic colors respect accessibility settings
- System handles Dynamic Type and contrast automatically
- Maintains dark aesthetic while being system-aware

**Alternatives considered**:
- Keep hardcoded colors: Rejected - won't integrate with Liquid Glass
- Use light mode: Rejected - dark mode is core to InsGrids brand

### 2. Material Effects

**Decision**: Replace `Color.gray.opacity(0.3)` overlays with `.ultraThinMaterial` or `.regularMaterial`.

**Implementation**:
```swift
// Before
.background(Color.gray.opacity(0.3))

// After
.background(.ultraThinMaterial)
```

**Rationale**:
- Materials automatically adapt to content behind them
- Provides depth and visual hierarchy consistent with iOS 26
- Better performance (system-optimized rendering)

### 3. Button Styling

**Decision**: Use custom `ButtonStyle` that incorporates glass effects while maintaining InsGrids branding.

**Implementation approach**:
```swift
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }
}
```

**Rationale**:
- Maintains custom look while adopting system materials
- Reusable across the app
- Easy to adjust globally

### 4. Sheet Presentation

**Decision**: Add `.presentationBackground(.ultraThinMaterial)` to all sheets.

**Affected components**:
- `GridDimensionPicker`
- `ColorPickerSheet`
- `StickerPickerView`
- `FontPickerView`
- `PresetsSheet`

### 5. App Icon

**Decision**: Create 3-layer icon using Icon Composer in Xcode 26.

**Layer structure**:
- **Background**: Solid gradient or color
- **Midground**: Grid pattern or subtle texture
- **Foreground**: InsGrids logo mark

**Rationale**: Required for iOS 26's dynamic icon effects (parallax, depth on home screen).

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Loss of brand identity with system materials | Use `.preferredColorScheme(.dark)` and custom accent colors |
| Visual inconsistency during transition | Batch update all views in single release |
| Icon Composer learning curve | Follow Apple's WWDC 2025 session on icon design |
| Potential performance impact from materials | Materials are GPU-accelerated; monitor on older A13 devices |

## Migration Plan

### Phase 1: Foundation (Non-breaking)
1. Create `GlassButtonStyle` and other custom styles
2. Add color constants for semantic colors
3. Test on iOS 26 simulator

### Phase 2: View Updates
1. Update `ContentView.swift` (main screen)
2. Update `GridEditingView.swift` (grid editor)
3. Update all sheet components
4. Update overlay views

### Phase 3: App Icon
1. Export current icon layers
2. Create multi-layer icon in Icon Composer
3. Test dynamic effects

### Phase 4: Validation
1. Test on physical devices (A13+)
2. Verify light/dark mode behavior
3. Check accessibility (Dynamic Type, High Contrast)

## Open Questions

1. ~~Should we create a custom `glassBackgroundEffect` modifier for consistency?~~ **RESOLVED**: Using SwiftUI's built-in materials (`.ultraThinMaterial`, `.regularMaterial`) directly is sufficient and more maintainable.
2. ~~Do we need separate styles for primary vs secondary buttons?~~ **RESOLVED**: Yes - created `GlassPrimaryButtonStyle` and `GlassSecondaryButtonStyle` in `GlassButtonStyle.swift`.
3. ~~Should toolbar backgrounds also use materials or remain opaque for clarity?~~ **RESOLVED**: Using `.bar` material for toolbars provides the right balance of clarity and visual consistency.

## Implementation Notes

### UI Consistency (2026-01-19)
During implementation, identified and fixed additional UI consistency issues:

1. **Save/Export Button Unification**: All editing modes (GridEditingView, EditingView, LayoutEditorView) now use identical blue "Save" button styling for consistency. Added `.fixedSize()` to prevent text wrapping on narrow screens.

2. **Grid Dimension Display**: Fixed "3×3" grid size button to display on single line using `.fixedSize()` and `.lineLimit(1)` modifiers.
