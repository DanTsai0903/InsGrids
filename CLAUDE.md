<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Generate Xcode project (required before first build)
xcodegen generate

# Open project
open InsGrids.xcodeproj

# Build from command line
xcodebuild -project InsGrids.xcodeproj -target InsGrids -configuration Debug -sdk iphonesimulator

# Generate unsigned IPA for AltStore distribution
./generate_ipa.sh
```

Build in Xcode with Cmd+R. No tests exist yet.

## Architecture

**MVVM with Proxy Image Workflow**

The app uses a "Low-Res Edit, High-Res Export" architecture to handle 48MP images:
- User edits with 1200px downsampled proxies for smooth 60fps UI
- Original full-resolution images are cached to disk (`/Caches/original_images/`)
- At export, originals are loaded per-tile and processed with `autoreleasepool` to prevent OOM

**Key Components:**

- `GridViewModel` (InstaBorderApp/ViewModels/GridViewModel.swift) - Central state management for the freeform canvas. Handles image CRUD, undo stack (20 levels), auto-save to disk every 5 seconds, and tiled high-res export.

- `PhotoEditorEngine` (InstaBorderApp/Utilities/PhotoEditorEngine.swift) - Metal-backed CoreImage pipeline for real-time photo adjustments (exposure, contrast, tone curves, filters). Uses `CIContext` with GPU acceleration.

- `ImageProcessor` (InstaBorderApp/Models/ImageProcessor.swift) - Singleton for border/aspect-ratio processing with 12MP output limit.

- `ImageExporter` (InstaBorderApp/Utilities/ImageExporter.swift) - Saves processed images to Photo Library with minimal permissions (`.addOnly`).

**Data Flow:**
```
PhotoPicker → Data → downsample(1200px) → CanvasImage (proxy)
                  ↓
           saveOriginal() → /Caches/original_images/{uuid}.jpg

Export: loadOriginal(uuid) → PhotoEditorEngine.render() → tile render → Photo Library
```

**Localization:** English (`en.lproj/`) and Traditional Chinese (`zh-Hant.lproj/`). Add strings to both `Localizable.strings` files.

## OpenSpec Workflow

This project uses OpenSpec for spec-driven development. When planning features:

1. Read `openspec/AGENTS.md` for full workflow
2. Check existing specs: `openspec list --specs`
3. Check active changes: `openspec list`
4. Create proposals in `openspec/changes/[change-id]/` with `proposal.md`, `tasks.md`, and spec deltas

Skip proposals for: bug fixes, typos, dependency updates, config changes.

## Key Constraints

- **Memory:** Use `autoreleasepool` for batch operations. Max 12MP output. Serial processing (not parallel) for high-res images.
- **No external dependencies:** First-party Apple frameworks only.
- **Privacy:** `.addOnly` photo permission. No cloud, no analytics.
- **XcodeGen:** Never edit `.xcodeproj` directly—modify `project.yml` and regenerate.

## iOS 26 Liquid Glass Styling Conventions

The app follows iOS 26 Liquid Glass design system. When styling UI components:

**Backgrounds:**
- Use `ThemeColors.background` (semantic `Color(.systemBackground)`) instead of hardcoded colors
- App enforces dark mode via `.preferredColorScheme(.dark)` in root `WindowGroup`

**Materials:**
- Use `.ultraThinMaterial` for overlays, buttons, and lightweight UI elements
- Use `.regularMaterial` for sheets and prominent panels
- Use `.bar` for toolbars and navigation bars
- Avoid `Color.opacity()` for glass effects—use materials instead

**Buttons:**
- Apply `GlassPrimaryButtonStyle` for primary actions (blue fill)
- Apply `GlassSecondaryButtonStyle` for secondary actions (material fill)
- Apply `GlassToolbarButtonStyle` for toolbar buttons (compact material)
- Apply `GlassIconButtonStyle` for icon-only buttons
- Use `.fixedSize(horizontal: true, vertical: false)` to prevent text wrapping

**Colors:**
- Use semantic colors from `ThemeColors` enum where possible
- Use system colors (`.blue`, `.primary`, `.secondary`) for consistency
- Avoid hardcoded RGB values except for actual color swatches/pickers

**ViewBuilder Pattern:**
When mixing `Color` and `Material` types in conditional backgrounds, use ViewBuilder with if/else instead of ternary operators:

```swift
// ✅ Correct
.background {
    if isSelected {
        RoundedRectangle(cornerRadius: 8).fill(Color.blue)
    } else {
        RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial)
    }
}

// ❌ Incorrect (type mismatch)
.background(isSelected ? Color.blue : .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
```
