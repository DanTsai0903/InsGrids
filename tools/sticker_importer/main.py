"""Sticker importer tool for InsGrids.

This tool imports stickers from external folders into the iOS app's Assets.xcassets
and updates CustomStickerCategory.swift accordingly.
"""

import json
import os
import re
import shutil
from pathlib import Path
from typing import Optional

import typer
from dotenv import load_dotenv
from PIL import Image
from rich.console import Console
from rich.progress import track

# Load environment variables from .env file
load_dotenv()

try:
    from google import genai
    from google.genai.types import GenerateContentConfig
except ImportError:
    genai = None

app = typer.Typer(help="Import stickers into InsGrids iOS app")
console = Console()

# Paths
PROJECT_ROOT = Path(__file__).parent.parent.parent
ASSETS_PATH = PROJECT_ROOT / "InstaBorderApp" / "Assets.xcassets" / "Stickers"
SWIFT_FILE = PROJECT_ROOT / "InstaBorderApp" / "Models" / "CustomStickerCategory.swift"


def strip_id_prefix(folder_name: str) -> str:
    """Strip numeric ID prefix from folder name (e.g., '4193240-christmas' -> 'christmas')."""
    match = re.match(r"^\d+-(.+)$", folder_name)
    return match.group(1) if match else folder_name


def find_image_source(category_path: Path) -> tuple[Optional[Path], Optional[str]]:
    """Find image source folder, prioritizing SVG over PNG.
    
    Returns:
        (source_path, format_type) where format_type is 'svg' or 'png'
    """
    svg_path = category_path / "svg"
    png_path = category_path / "png"
    
    if svg_path.exists() and svg_path.is_dir():
        return svg_path, "svg"
    elif png_path.exists() and png_path.is_dir():
        return png_path, "png"
    return None, None


def create_imageset(sticker_name: str, image_path: Path, category_folder: Path, format_type: str):
    """Create .imageset folder with Contents.json and image file."""
    imageset_path = category_folder / f"{sticker_name}.imageset"
    imageset_path.mkdir(parents=True, exist_ok=True)
    
    # Copy image file
    extension = ".svg" if format_type == "svg" else ".png"
    dest_image = imageset_path / f"image{extension}"
    shutil.copy2(image_path, dest_image)
    
    # Create Contents.json
    if format_type == "svg":
        contents = {
            "images": [
                {
                    "filename": f"image{extension}",
                    "idiom": "universal"
                }
            ],
            "info": {
                "author": "xcode",
                "version": 1
            },
            "properties": {
                "preserves-vector-representation": True
            }
        }
    else:  # PNG
        contents = {
            "images": [
                {
                    "filename": f"image{extension}",
                    "idiom": "universal",
                    "scale": "1x"
                }
            ],
            "info": {
                "author": "xcode",
                "version": 1
            }
        }
    
    contents_file = imageset_path / "Contents.json"
    contents_file.write_text(json.dumps(contents, indent=2))


def generate_label(image_path: Path, api_key: Optional[str] = None) -> list[str]:
    """Generate labels for an image using Gemini API."""
    if not genai or not api_key:
        return []
    
    try:
        client = genai.Client(api_key=api_key)
        
        # Upload the file for processing
        uploaded_file = client.files.upload(file=str(image_path))
        
        # Generate labels
        response = client.models.generate_content(
            model="gemini-2.0-flash-exp",
            config=GenerateContentConfig(
                system_instruction="You are a helpful assistant that generates keywords for stickers. Provide at least 5 relevant keywords for each image."
            ),
            contents=[
                "Describe this sticker image with 5-8 relevant keywords, separated by commas. Only return the keywords, nothing else. Focus on the object, style, and mood.",
                uploaded_file
            ]
        )
        
        # Delete the uploaded file
        client.files.delete(name=uploaded_file.name)
        
        keywords = response.text.strip().split(",")
        return [k.strip().lower() for k in keywords if k.strip()]
    except Exception as e:
        error_msg = str(e)
        if "429" in error_msg or "RESOURCE_EXHAUSTED" in error_msg:
             console.print(f"[red]Quota exceeded (429). Disabling AI labeling for remaining stickers.[/red]")
             return ["__QUOTA_EXCEEDED__"]
        
        console.print(f"[yellow]Warning: AI labeling failed for {image_path.name}: {e}[/yellow]")
        return []


def update_swift_file(categories: dict[str, list[str]]):
    """Update CustomStickerCategory.swift with new categories and stickers."""
    if not SWIFT_FILE.exists():
        console.print(f"[red]Error: {SWIFT_FILE} not found[/red]")
        return
    
    content = SWIFT_FILE.read_text()
    
    # Find the allCategories array
    pattern = r"(static let allCategories: \[CustomStickerCategory\] = \[)(.*?)(\n    \])"
    match = re.search(pattern, content, re.DOTALL)
    
    if not match:
        console.print("[red]Error: Could not find allCategories array[/red]")
        return
    
    existing_content = match.group(2)
    
    # Parse existing categories
    existing_categories = {}
    category_pattern = r'CustomStickerCategory\(\s*name:\s*"([^"]+)",\s*localizedKey:\s*"([^"]+)",\s*stickers:\s*\[(.*?)\]'
    
    # CustomSticker(name: "...", labels: [...])
    sticker_pattern = r'CustomSticker\(name:\s*"([^"]+)",\s*labels:\s*\[(.*?)\]\)'
    
    for cat_match in re.finditer(category_pattern, existing_content, re.DOTALL):
        cat_name = cat_match.group(1)
        stickers_str = cat_match.group(3)
        
        stickers = []
        for s_match in re.finditer(sticker_pattern, stickers_str, re.DOTALL):
            s_name = s_match.group(1)
            s_labels = [l.strip().strip('"') for l in s_match.group(2).split(",") if l.strip()]
            stickers.append({"name": s_name, "labels": s_labels})
            
        existing_categories[cat_name] = stickers
    
    # Merge with new categories
    for cat_name, new_stickers in categories.items():
        if cat_name in existing_categories:
            # Append to existing, avoiding duplicates
            existing_names = {s["name"] for s in existing_categories[cat_name]}
            for sticker in new_stickers:
                if sticker["name"] not in existing_names:
                    existing_categories[cat_name].append(sticker)
        else:
            # New category
            existing_categories[cat_name] = new_stickers
    
    # Generate new array content
    new_entries = []
    for cat_name, stickers in sorted(existing_categories.items()):
        sticker_objs = []
        for s in stickers:
            label_list = ", ".join(f'"{l}"' for l in s["labels"])
            sticker_objs.append(f'CustomSticker(name: "{s["name"]}", labels: [{label_list}])')
        
        sticker_list_str = ",\n                ".join(sticker_objs)
        localized_key = f"sticker.category.{cat_name.lower().replace(' ', '')}"
        entry = f'''        CustomStickerCategory(
            name: "{cat_name}",
            localizedKey: "{localized_key}",
            stickers: [
                {sticker_list_str}
            ]
        )'''
        new_entries.append(entry)
    
    new_content = f"{match.group(1)}\n{',\n'.join(new_entries)}\n    {match.group(3)}"
    updated_content = content[:match.start()] + new_content + content[match.end():]
    
    SWIFT_FILE.write_text(updated_content)
    console.print(f"[green]✓[/green] Updated {SWIFT_FILE.name}")


@app.command()
def import_stickers(
    source_dir: Path = typer.Argument(..., help="Source directory containing sticker folders"),
    ai_label: bool = typer.Option(False, "--ai-label", "-a", help="Generate AI labels for stickers"),
    gemini_key: Optional[str] = typer.Option(None, "--gemini-key", help="Gemini API key (or set GEMINI_API_KEY env var)")
):
    """Import stickers from external folders into InsGrids."""
    if not source_dir.exists():
        console.print(f"[red]Error: {source_dir} does not exist[/red]")
        raise typer.Exit(1)
    
    # Get Gemini key if AI labeling requested
    api_key = gemini_key or os.getenv("GEMINI_API_KEY")
    if ai_label and not api_key:
        console.print("[yellow]Warning: --ai-label specified but no API key found. Skipping AI labeling.[/yellow]")
        ai_label = False
    
    console.print(f"[bold]Importing stickers from:[/bold] {source_dir}")
    console.print(f"[bold]Target assets:[/bold] {ASSETS_PATH}")
    
    # Ensure Stickers folder exists
    ASSETS_PATH.mkdir(parents=True, exist_ok=True)
    
    # Scan categories
    categories_data = {}
    
    for category_dir in source_dir.iterdir():
        if not category_dir.is_dir() or category_dir.name.startswith("."):
            continue
        
        category_name = strip_id_prefix(category_dir.name)
        source_path, format_type = find_image_source(category_dir)
        
        if not source_path:
            console.print(f"[yellow]Skipping {category_dir.name}: no svg or png folder found[/yellow]")
            continue
        
        console.print(f"\n[cyan]{category_name}[/cyan] ({format_type.upper()})")
        
        # Create category folder in assets
        category_folder = ASSETS_PATH / category_name
        category_folder.mkdir(exist_ok=True)
        
        # Process images
        stickers = []
        image_extensions = [".svg"] if format_type == "svg" else [".png"]
        images = [f for f in source_path.iterdir() if f.suffix.lower() in image_extensions]
        
        for image_file in track(images, description=f"Processing {category_name}"):
            sticker_name = image_file.stem.lower().replace(" ", "-")
            
            # Create imageset
            create_imageset(sticker_name, image_file, category_folder, format_type)
            
            # AI labeling
            labels = []
            if ai_label:
                labels = generate_label(image_file, api_key)
                if labels and labels[0] == "__QUOTA_EXCEEDED__":
                    ai_label = False
                    labels = []
                elif labels:
                    console.print(f"  [dim]{sticker_name}: {', '.join(labels)}[/dim]")
            
            stickers.append({"name": sticker_name, "labels": labels})
        
        categories_data[category_name] = stickers
        console.print(f"[green]✓[/green] Imported {len(stickers)} stickers")
    
    # Update Swift file
    if categories_data:
        console.print("\n[bold]Updating Swift code...[/bold]")
        update_swift_file(categories_data)
        console.print(f"\n[green]✓[/green] Successfully imported {sum(len(s) for s in categories_data.values())} stickers across {len(categories_data)} categories")
    else:
        console.print("[yellow]No stickers found to import[/yellow]")


if __name__ == "__main__":
    app()
