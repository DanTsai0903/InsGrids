# Technical Design: Sticker Automation Agent

## Context

This agent automates the sticker production pipeline for the InsGrids iOS app. It uses Google's Gemini API to generate sticker images, presents them to the user for selection, and automatically integrates approved stickers into the Xcode project.

## Goals
- Generate high-quality stickers using AI (Nano Banana models)
- Provide interactive selection workflow
- Automate asset catalog and code updates
- Support both fast generation (Flash) and high-quality (Pro) modes

## Non-Goals
- Real-time in-app sticker generation
- Automatic categorization without user review
- Support for non-iOS platforms

## Architecture

### Components

```
sticker_agent/
├── __init__.py
├── main.py              # CLI entry point (Typer)
├── generator.py         # GeminiImageGenerator
├── processor.py         # ImageProcessor
├── analyzer.py          # CategoryAnalyzer
├── asset_manager.py     # AssetManager
├── code_modifier.py     # CodeModifier
└── config.py            # Configuration management
```

### Technology Stack
- **Python 3.11+** with `uv` package manager
- **google-genai** for image generation
- **Pillow** for image processing
- **Typer** for CLI interface
- **Rich** for beautiful terminal output
- **python-dotenv** for environment configuration

## API Usage

### Gemini API Setup

1. **Install the SDK:**
```bash
uv add google-genai
```

2. **Set up API key:**
```bash
# .env file
GEMINI_API_KEY=your_api_key_here
```

3. **Get your API key from:**
https://ai.google.dev/gemini-api/docs/api-key

### Image Generation Examples

#### Using Nano Banana (Fast, 1024px)

```python
from google import genai
from PIL import Image

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

prompt = "A cute pixel art cat sticker with transparent background"

response = client.models.generate_content(
    model="gemini-2.5-flash-image",
    contents=[prompt],
)

# Save the generated image
for part in response.parts:
    if part.inline_data is not None:
        image = part.as_image()
        image.save("sticker_variant_1.png")
```

#### Using Nano Banana Pro (High Quality, up to 4K)

```python
from google import genai

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

prompt = "A professional quality heart emoji sticker with glossy effect"

response = client.models.generate_content(
    model="gemini-3-pro-image-preview",
    contents=[prompt],
)

for part in response.parts:
    if part.inline_data is not None:
        image = part.as_image()
        image.save("sticker_pro_variant_1.png")
```

#### Generating Multiple Variants

```python
def generate_variants(prompt: str, count: int = 4, use_pro: bool = False):
    """Generate multiple sticker variants."""
    model = "gemini-3-pro-image-preview" if use_pro else "gemini-2.5-flash-image"
    client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
    
    variants = []
    for i in range(count):
        response = client.models.generate_content(
            model=model,
            contents=[prompt],
        )
        
        for part in response.parts:
            if part.inline_data is not None:
                image = part.as_image()
                filename = f"variant_{i+1}.png"
                image.save(filename)
                variants.append(filename)
    
    return variants
```

### Model Selection Guide

| Model | Name | Speed | Quality | Resolution | Use Case |
|-------|------|-------|---------|------------|----------|
| `gemini-2.5-flash-image` | Nano Banana | Fast | Good | 1024px | Quick iterations, high volume |
| `gemini-3-pro-image-preview` | Nano Banana Pro | Slower | Excellent | Up to 4K | Final assets, professional quality |

## Decisions

### Decision: Use Gemini API Directly
**Why:** Simpler than MCP server, fewer dependencies, official SDK support.
**Alternatives considered:** 
- MCP server (rejected - unnecessary complexity)
- DALL-E API (rejected - user preference for Gemini)

### Decision: Interactive Selection Flow
**Why:** User wants manual control over which stickers to include.
**Implementation:** Generate → Display in terminal/browser → User selects → Ingest.

### Decision: Python with `uv`
**Why:** Aligns with user's development preferences and project setup.

### Decision: Transparent Backgrounds via Prompts
**Why:** Request transparent backgrounds in prompts to Gemini API rather than post-processing.
**Implementation:** Include "with transparent background" in all generation prompts.

### Decision: Batch Processing Support
**Why:** Enable efficient bulk sticker generation for themed sets.
**Implementation:** Add `--batch` mode to generate multiple stickers from a list of prompts.

### Decision: Hybrid Category Assignment
**Why:** Provide both AI-assisted suggestions and manual override for flexibility.
**Implementation:** Use Gemini API to suggest categories, but allow user to modify before ingestion.

## Integration Points

### Assets.xcassets Structure

```
Assets.xcassets/
└── Stickers/
    └── hearts/
        └── glossy-heart.imageset/
            ├── Contents.json
            └── glossy-heart.png
```

### CustomStickerCategory.swift Modification

The agent will update this file to add new stickers to categories:

```swift
static let allCategories: [CustomStickerCategory] = [
    CustomStickerCategory(
        name: "Hearts",
        localizedKey: "sticker.category.hearts",
        stickers: ["glossy-heart", "pixel-heart", "rainbow-heart"]
    )
]
```

## Risks & Trade-offs

| Risk | Mitigation |
|------|------------|
| API rate limits | Implement retry logic with exponential backoff |
| Generated images may need manual cleanup | Provide re-generation option |
| Swift code parsing errors | Use ast/regex carefully, validate syntax |
| Asset naming conflicts | Check existing assets before adding |

## Migration Plan

N/A - This is a new tool, no migration needed.

## Implementation Notes

### Transparent Backgrounds
Always append "with transparent background, no drop shadow, clean cutout style" to user prompts.

### Batch Mode
```bash
uv run sticker-agent batch prompts.txt --category hearts
```

### Category Assignment
After generation, use Gemini to analyze the image and suggest a category, then present to user for confirmation.
