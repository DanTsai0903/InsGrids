1. [ ] Add `imagehash` to `tools/sticker_importer/pyproject.toml`
2. [ ] Create `tools/sticker_importer/hashing.py` for hash calculation (handling SVG/PNG via `qlmanage` or `PIL`)
3. [ ] Refactor `main.py`: Remove `ai_label` flag from `import_stickers`
4. [ ] Implement `label-stickers` command in `main.py`
5. [ ] Implement duplicate detection and renaming logic in `import_stickers`
6. [ ] Verify the workflow with sample stickers
