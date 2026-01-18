# Tasks: Add Customizable N×M Grid Template

> **Deliverable**: Users can create custom grid layouts with arbitrary row/column counts (1-6 each)

---

## 1. Add Grid Generation Function

**Scope**: `InstaBorderApp/Models/LayoutTemplate.swift`

**Work**:
- Add `static func customGrid(rows: Int, columns: Int) -> LayoutTemplate`
- Implement uniform grid calculation (each slot = 1/columns wide, 1/rows high)
- Generate template ID as `"custom_{columns}x{rows}"`
- Generate localized name as `"{columns}×{rows} Grid"`

**Validation**:
- Unit test: 2×3 grid produces 6 slots with correct dimensions
- Unit test: 1×1 grid produces 1 slot covering full space
- Unit test: 30×30 grid produces 900 slots

**Dependencies**: None

---

## 2. Create Custom Grid Input Sheet

**Scope**: New file `InstaBorderApp/Views/Components/CustomGridInputSheet.swift`

**Work**:
- Create SwiftUI sheet with:
  - Stepper for columns (1-30, default 2)
  - Stepper for rows (1-30, default 2)
  - Visual grid preview
  - "Create Grid" and "Cancel" buttons
- Add state management
- Add callback closure to return generated template
- Implement live preview that updates as steppers change

**Validation**:
- Manual test: Sheet appears with default 2×2
- Manual test: Adjusting steppers updates preview
- Manual test: "Create Grid" returns correct template
- Manual test: "Cancel" dismisses without action

**Dependencies**: Task 1 (uses `customGrid()` function)

---

## 3. Add Custom Grid Card to Template Picker

**Scope**: `InstaBorderApp/Views/LayoutTemplateSelectView.swift`

**Work**:
- Add "Custom Grid" card with distinct visual styling
- Add icon (grid with "+" or adjustment symbol)
- Position prominently in template picker (recommend as first card)
- Wire tap gesture to present `CustomGridInputSheet`
- Pass callback to receive generated template
- Navigate to photo picker with generated template

**Validation**:
- Manual test: "Custom Grid" card is visible and discoverable
- Manual test: Tapping card opens input sheet
- Manual test: Creating grid proceeds to photo selection
- Manual test: Flow works end-to-end (select custom grid → input dimensions → add photos → edit)

**Dependencies**: Task 2 (requires `CustomGridInputSheet`)

---

## 4. Add Localization Strings

**Scope**: 
- `InstaBorderApp/Resources/en.lproj/Localizable.strings`
- `InstaBorderApp/Resources/zh-Hant.lproj/Localizable.strings`

**Work**:
- Add English strings:
  - `"template.customGrid" = "Custom Grid";`
  - `"template.customGrid.subtitle" = "Choose your size";`
  - `"customGrid.columns" = "Columns";`
  - `"customGrid.rows" = "Rows";`
  - `"customGrid.create" = "Create Grid";`
  - `"customGrid.cancel" = "Cancel";`
  - `"customGrid.preview" = "Preview";`
- Add Traditional Chinese translations

**Validation**:
- Manual test: Switch device language to English, verify strings
- Manual test: Switch device language to Traditional Chinese, verify strings

**Dependencies**: Task 2 and 3 (strings used in UI)

---

## 5. Integration Testing

**Scope**: End-to-end feature validation

**Work**:
- Test custom grids with existing features:
  - Inner spacing adjustment
  - Outer border width
  - Corner radius
  - Background color
  - Aspect ratio changes (1:1, 4:5, 16:9, 9:16)
  - Draggable lines (verify auto-detection works)
  - Photo manipulation (scale, pan)
  - Template switching
- Test edge cases:
  - 1×1 grid (1 slot)
  - 1×30 and 30×1 grids (single row/column)
  - 30×30 grid (900 slots, maximum)
  - Large grids (20×20) for performance
  - Various aspect ratios

**Validation**:
- Manual test checklist:
  - [ ] 2×2 grid with inner spacing works correctly
  - [ ] 3×3 grid has correct draggable lines (2 horizontal, 2 vertical)
  - [ ] 4×1 grid has 3 vertical draggable lines
  - [ ] 30×30 grid renders and performs acceptably
  - [ ] 20×20 grid renders and performs well
  - [ ] Custom grid switches between aspect ratios correctly
  - [ ] Photos can be added/removed from custom grid slots
  - [ ] Export works correctly with custom grids

**Dependencies**: Tasks 1-4 (complete implementation)

---

## 6. Documentation Update

**Scope**: `.agent/workflows/add-layout-template.md`

**Work**:
- Add section about custom grids to workflow documentation
- Document that `customGrid()` function can be used for dynamic generation
- Note that user can create custom grids through UI

**Validation**:
- Review: Workflow documentation is clear and accurate

**Dependencies**: Task 5 (implementation complete and tested)
