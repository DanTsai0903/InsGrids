# Tasks: Add External Sticker Automation Tool

## 1. Tool Creation
- [ ] 1.1 Scaffold `agents/sticker_importer` project with `uv`.
- [ ] 1.2 Implement `main.py` with `typer` and `rich`.
- [ ] 1.3 Implement `AssetManager` to handle `.imageset` creation.
- [ ] 1.4 Implement `LabelGenerator` using `google-genai` to caption images.
- [ ] 1.5 Implement `CodeModifier` to parse and update `CustomStickerCategory.swift`.

## 2. Integration
- [ ] 2.1 Implement source folder scanning logic (Category detection, SVG vs PNG priority).
- [ ] 2.2 Wire up the `import` command with optional `--ai-label` flag.
- [ ] 2.3 Create `wrapper.sh` for easy execution.

## 3. Verification
- [ ] 3.1 Test import on a sample folder from Desktop.
- [ ] 3.2 Verify `Assets.xcassets` integrity in Xcode (visual check or build).
- [ ] 3.3 Verify `CustomStickerCategory.swift` compiles correctly.
