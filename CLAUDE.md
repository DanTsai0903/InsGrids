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
