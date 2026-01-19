# [PAUSED] Sticker Automation Agent
> [!WARNING]
> This feature is currently PAUSED and ARCHIVED due to Gemini API quota limitations (429 RESOURCE_EXHAUSTED). The code has been moved to `agents/_sticker_agent_paused`.

## 1. Environment Setup
- [ ] 1.1 Create `agents/sticker_agent` directory
- [ ] 1.2 Initialize `uv` project with `pyproject.toml`
- [ ] 1.3 Add dependencies: `google-genai`, `pillow`, `typer`, `rich`, `python-dotenv`
- [ ] 1.4 Configure `.env` for `GEMINI_API_KEY`

## 2. Core Logic
- [ ] 2.1 Implement `GeminiImageGenerator` class (uses `google.genai.Client`)
- [ ] 2.2 Support both `gemini-2.5-flash-image` and `gemini-3-pro-image-preview`
- [ ] 2.3 Implement `ImageProcessor` (Resizing to 1024px or appropriate size)
- [ ] 2.4 Implement `CategoryAnalyzer` (AI suggestions + manual override)

## 3. Integration Logic
- [ ] 3.1 Implement `AssetManager` (Write to `.imageset`)
- [ ] 3.2 Implement `CodeModifier` (Update `CustomStickerCategory.swift`)

## 4. CLI Interface
- [ ] 4.1 Create main entry point with commands: `generate`, `batch`, `ingest`
- [ ] 4.2 Add configuration handling (API keys)
- [ ] 4.3 Implement prompt enhancement (auto-add transparent background)
- [ ] 4.4 Implement AI-assisted category suggestion

## 5. Verification
- [ ] 5.1 Test with a sample prompt
- [ ] 5.2 Verify iOS app build
