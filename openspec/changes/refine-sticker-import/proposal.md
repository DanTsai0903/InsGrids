# Refine Sticker Import Workflow

## Summary
Modify the sticker import process to disable automatic AI labeling, implement perceptual hashing for duplicate detection (converting SVG to PNG for calculation), and append sticker hashes to filenames.

## Motivation
- **Manual AI Labeling**: To save API quota and allow selective labeling.
- **Duplicate Detection**: To prevent importing identical stickers even if filenames differ, especially across different formats (SVG/PNG).
- **Naming Convention**: To ensure uniqueness and traceability of stickers.

## Proposed Solution
- Update `sticker-importer` tool.
- Split labeling into a separate command.
- Add `imagehash` dependency.
- Implement pHash (Perceptual Hash) with Hamming distance check.
