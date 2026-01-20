# Design: Refine Sticker Import

## Components

### 1. Sticker Importer CLI (`tools/sticker_importer`)

#### `import_stickers` Command
- **Remove** `ai_label` option.
- **Hashing**:
    - Calculate pHash (Perceptual Hash) for each image.
    - If SVG: Render to PNG (512x512) using `qlmanage` (macOS native) or `cairosvg` to generate a raster for hashing.
- **Naming**:
    - Format: `{original_stem}_{hash}`
    - Example: `christmas-tree_a1b2c3d4e5f6g7h8`
- **Duplicate Detection**:
    - Before importing, scan all existing stickers in `CustomStickerCategory.swift`.
    - Extract hashes from existing sticker names (assuming `{name}_{hash}` format).
    - Compare new image hash against valid existing hashes.
    - **Threshold**: Hamming distance < 10 (configurable).
    - If duplicate: Skip import and log warning.

#### `label_stickers` Command (New)
- **Purpose**: Batch label stickers that are already imported but missing labels.
- **Logic**:
    - Parse `CustomStickerCategory.swift`.
    - Identify stickers where `labels` is empty or only contains placeholders.
    - Locate source image (reconstruct path from `Assets.xcassets`).
    - Call Gemini API.
    - Update `CustomStickerCategory.swift` in place.

## Data Structures
- **Sticker Name Format**: `{original_name}_{hash}`
    - Regular expression to parse: `r"^(.*)_([a-f0-9]{16})$"`

## Dependencies
- `imagehash`: For Perceptual Hashing (pHash).
- `Pillow`: Existing.
- `qlmanage` (System Tool) or `cairosvg`:
    - Since we are on macOS, `qlmanage -t -s 512 -o <tmp_dir> <svg_file>` is a lightweight way to rasterize SVG without installing heavy system dependencies like libcairo. we will attempt `qlmanage` first.

## Duplicate Logic
- **Algorithm**: pHash (Perceptual Hash) using DCT.
- **Comparison**: Hamming distance.
- **Scope**: Compare against ALL currently registered stickers in `CustomStickerCategory.swift`.
