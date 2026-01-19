# Tasks: iOS 26 Liquid Glass Adaptation

## 1. Foundation - Style Definitions

- [x] 1.1 Create `Styles/GlassButtonStyle.swift` with primary and secondary variants
- [x] 1.2 Create `Styles/ThemeColors.swift` with semantic color constants
- [x] 1.3 Add `.preferredColorScheme(.dark)` to root `WindowGroup` in `InstaBorderApp.swift`

## 2. Main Views - Background Updates

- [x] 2.1 Update `ContentView.swift`:
  - [x] Replace `Color.black.ignoresSafeArea()` with `ThemeColors.background`
  - [x] Replace gradient `Color.blue.opacity(0.15)` with subtle material
  - [x] Update button backgrounds to use materials
  - [x] Apply `GlassButtonStyle` to action buttons

- [x] 2.2 Update `GridEditingView.swift`:
  - [x] Replace toolbar `Color.black` background with `.bar` material
  - [x] Update processing overlay to use `.ultraThinMaterial`
  - [x] Update button styles in toolbar

- [x] 2.3 Update `EditingView.swift`:
  - [x] Replace hardcoded backgrounds with semantic colors
  - [x] Update control panel backgrounds to materials

- [x] 2.4 Update `LayoutEditorView.swift`:
  - [x] Apply consistent material backgrounds
  - [x] Update toolbar styling

- [x] 2.5 Update `LayoutTemplateSelectView.swift`:
  - [x] Apply semantic background colors
  - [x] Update template card styling

## 3. Component Views - Sheet Updates

- [x] 3.1 Update `ColorPickerSheet` (in GridEditingView.swift):
  - [x] Add `.presentationBackground(.regularMaterial)`
  - [ ] Update preset color circles styling

- [x] 3.2 Update `GridDimensionPicker.swift`:
  - [x] Add material presentation background
  - [ ] Update stepper/picker styling

- [x] 3.3 Update `StickerPickerView.swift`:
  - [x] Add material presentation background
  - [x] Update category tabs styling (uses system segmented picker)

- [x] 3.4 Update `FontPickerView.swift`:
  - [x] Add material presentation background (via TextEditorView)
  - [ ] Update font list styling

- [x] 3.5 Update `PresetsSheet.swift`:
  - [x] Add material presentation background (via EditingView caller)
  - [x] Update preset list styling (uses system List)

- [x] 3.6 Update `EmojiPickerView.swift`:
  - [x] Update category tabs styling

- [ ] 3.7 Update `CustomColorPaletteView.swift`:
  - [ ] Update color swatch styling

## 4. Overlay Views

- [x] 4.1 Update `ImageCropView` (in GridEditingView.swift):
  - [x] Update header/footer backgrounds to materials
  - [x] Update ratio button styling

- [x] 4.2 Update `PhotoEditorView.swift`:
  - [x] Update toolbar backgrounds
  - [x] Update slider controls styling

- [x] 4.3 Update `TextEditorView.swift`:
  - [x] Update editor panel backgrounds
  - [x] Update control button styling

- [ ] 4.4 Update `EyedropperOverlayView.swift`:
  - [ ] Update loupe/magnifier styling

## 4.5. UI Consistency Improvements

- [x] 4.5.1 Unify save/export button styling across all modes:
  - [x] GridEditingView: Change "Export" to blue "Save" button
  - [x] Match EditingView and LayoutEditorView button style
  - [x] Add `.fixedSize()` to prevent text wrapping

- [x] 4.5.2 Fix grid dimension button display:
  - [x] Add `.fixedSize()` and `.lineLimit(1)` to "3×3" text
  - [x] Ensure dimension text displays on single line

## 5. App Icon

- [ ] 5.1 Export current icon as separate layers (background, logo)
- [ ] 5.2 Open Icon Composer in Xcode 26
- [ ] 5.3 Create 3-layer icon structure:
  - [ ] Background layer (gradient)
  - [ ] Midground layer (grid pattern)
  - [ ] Foreground layer (InsGrids mark)
- [ ] 5.4 Export and replace `AppIcon.appiconset`
- [ ] 5.5 Update `project.yml` if asset catalog changes needed

## 6. Testing & Validation

- [ ] 6.1 Test on iOS 26 Simulator (iPhone 15 Pro)
- [ ] 6.2 Verify dark mode appearance consistency
- [ ] 6.3 Test light mode fallback behavior
- [ ] 6.4 Verify Dynamic Type scaling
- [ ] 6.5 Test on physical device (A13+ chip)
- [ ] 6.6 Verify app icon dynamic effects on home screen
- [ ] 6.7 Performance profiling on older supported devices

## 7. Documentation

- [ ] 7.1 Update CLAUDE.md with new styling conventions
- [ ] 7.2 Archive this change after deployment
