# Proposal: Add External Sticker Automation Tool

## Summary
Introduce a standalone Python-based tool (`agents/sticker_importer`) to automate the import of stickers from local Desktop folders into the InsGrids iOS application. This tool will streamline the process of adding new sticker content by handling asset creation (`.imageset`), file copying, and Swift code generation (`CustomStickerCategory.swift`).

## Problem
Currently, adding stickers requires manual work:
1. Creating `.imageset` folders in Xcode or Finder.
2. configuring `Contents.json` for each sticker.
3. Dragging and dropping images.
4. Manually updating the `CustomStickerCategory` enum in Swift code to include the new sticker names.

This is error-prone and tedious for large batches of stickers.

## Proposed Solution
Create a CLI tool `sticker-importer` that:
1. Scans a source directory (e.g., `~/Desktop/stickers`).
2. Detects categories from folder names (stripping ID prefixes).
3. Processes images, prioritizing `svg` format for vector scalability, falling back to `png`.
4. Directy generates the necessary `Assets.xcassets` structure.
5.  **[New]** Uses Google Gemini API to analyze each sticker and generate relevant keywords/labels.
6. Automatically updates `CustomStickerCategory.swift` with the new categories and sticker identifiers (map labels if model supports it).

## Goals
- Reduce sticker import time from hours to seconds.
- Ensure consistency in asset naming and structure.
- Prevent syntax errors in Swift code updates.
