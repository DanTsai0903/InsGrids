# Change: Add Sticker Automation Agent

## Why
Currently, adding stickers requires manually finding images, processing them, creating asset catalogs, and updating Swift code. To scale the sticker library, we need an automated pipeline that can generate and ingest stickers efficiently.

## What Changes
- Introduction of a new Python-based CLI tool: `sticker-agent`
- Integration with **Gemini API** for image generation (Nano Banana & Nano Banana Pro)
- **Interactive workflow**: User selects which generated stickers to keep
- Automated manipulation of `Assets.xcassets` and `CustomStickerCategory.swift`

## Impact
- **Affected specs**: New `automation` capability.
- **Affected code**: `InstaBorderApp/Models/CustomStickerCategory.swift` (via automation), `InstaBorderApp/Assets.xcassets` (via automation).
- **New tooling**: `agents/sticker_agent` directory managed by `uv`.
