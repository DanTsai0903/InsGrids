"""Sticker importer tool for InsGrids.

This tool imports stickers from external folders into the iOS app's Assets.xcassets
and updates CustomStickerCategory.swift accordingly.
"""

import json
import os
import re
import shutil
import sys
from pathlib import Path
from typing import Optional, Dict, List, Set, Tuple

import typer
import imagehash
from dotenv import load_dotenv
from rich.console import Console
from rich.progress import track

from hashing import compute_image_hash

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
# Ensure we are running from the correct place or finding the paths correctly
if "tools" in str(Path.cwd()):
     # If running from tools/sticker_importer or similar
     PROJECT_ROOT = Path(__file__).parent.parent.parent
else:
     # Fallback if running from root
     PROJECT_ROOT = Path.cwd()

ASSETS_PATH = PROJECT_ROOT / "InstaBorderApp" / "Assets.xcassets" / "Stickers"
SWIFT_FILE = PROJECT_ROOT / "InstaBorderApp" / "Models" / "CustomStickerCategory.swift"


def strip_id_prefix(folder_name: str) -> str:
    """Strip numeric ID prefix from folder name (e.g., '4193240-christmas' -> 'christmas')."""
    match = re.match(r"^\d+-(.+)$", folder_name)
    return match.group(1) if match else folder_name


def find_image_source(category_path: Path) -> Tuple[Optional[Path], Optional[str]]:
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


def generate_label_for_image(image_path: Path, api_key: str) -> list[str]:
    """Generate labels for an image using Gemini API."""
    if not genai:
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
             console.print(f"[red]Quota exceeded (429).[/red]")
             return ["__QUOTA_EXCEEDED__"]
        
        console.print(f"[yellow]Warning: AI labeling failed: {e}[/yellow]")
        return []


def parse_swift_file():
    """Parse existing stickers from Swift file.
    
    Returns:
         dict: {category_name: [{name: str, labels: [str]}]}
    """
    if not SWIFT_FILE.exists():
        return {}
    
    content = SWIFT_FILE.read_text()
    
    # Find the allCategories array
    pattern = r"(static let allCategories: \[CustomStickerCategory\] = \[)(.*?)(\n    \])"
    match = re.search(pattern, content, re.DOTALL)
    
    if not match:
        return {}
    
    existing_content = match.group(2)
    existing_categories = {}
    
    # helper to find balanced bracket end
    def find_closing_bracket(text: str, start_index: int) -> int:
        count = 0
        for i, char in enumerate(text[start_index:], start_index):
            if char == '[':
                count += 1
            elif char == ']':
                count -= 1
                if count == 0:
                    return i
        return -1

    cat_start_pattern = r'name:\s*"([^"]+)",\s*localizedKey:\s*"([^"]+)",\s*stickers:\s*\['
    
    current_pos = 0
    while True:
        match = re.search(cat_start_pattern, existing_content[current_pos:], re.DOTALL)
        if not match:
            break
            
        cat_name = match.group(1)
        # Calculate absolute start position of the match
        # match_start_abs = current_pos + match.start()
        # The stickers array starts after the match
        array_start_abs = current_pos + match.end() - 1 # point to the '['
        
        # Find the closing bracket for the stickers array
        array_end_abs = find_closing_bracket(existing_content, array_start_abs)
        
        if array_end_abs == -1:
            break
            
        stickers_str = existing_content[array_start_abs+1 : array_end_abs]
        
        # Parse individual stickers inside this block
        sticker_pattern = r'CustomSticker\(name:\s*"([^"]+)",\s*labels:\s*\[(.*?)\]\)'
        stickers = []
        for s_match in re.finditer(sticker_pattern, stickers_str, re.DOTALL):
            s_name = s_match.group(1)
            # Handle empty labels
            if not s_match.group(2).strip():
                s_labels = []
            else:
                s_labels = [l.strip().strip('"') for l in s_match.group(2).split(",") if l.strip()]
            stickers.append({"name": s_name, "labels": s_labels})
            
        existing_categories[cat_name] = stickers
        current_pos = array_end_abs
    
    return existing_categories


def extract_hash_from_name(name: str) -> Optional[str]:
    """Extract hash from sticker name format: name_hash"""
    # Look for 16 char hex suffix
    match = re.search(r"_([0-9a-f]{16})$", name)
    if match:
        return match.group(1)
    return None


@app.command()
def import_stickers(
    source_dir: Path = typer.Argument(..., help="Source directory containing sticker folders"),
    threshold: int = typer.Option(10, help="Hamming distance threshold for duplicate detection")
):
    """Import stickers with duplicate detection via pHash."""
    if not source_dir.exists():
        console.print(f"[red]Error: {source_dir} does not exist[/red]")
        raise typer.Exit(1)
    
    console.print(f"[bold]Importing stickers from:[/bold] {source_dir}")
    ASSETS_PATH.mkdir(parents=True, exist_ok=True)
    
    # 1. Load existing stickers and their hashes
    console.print("Loading existing stickers...")
    existing_categories = parse_swift_file()
    existing_hashes = [] # List of (hash_obj, name)
    
    count_existing = 0
    for cat, stickers in existing_categories.items():
        for s in stickers:
            h_str = extract_hash_from_name(s["name"])
            if h_str:
                try:
                    existing_hashes.append((imagehash.hex_to_hash(h_str), s["name"]))
                except:
                    pass
            count_existing += 1
            
    console.print(f"Found {count_existing} existing stickers ({len(existing_hashes)} with valid hashes).")

    # 2. Process new stickers
    categories_data = existing_categories.copy()
    
    # Track new hashes in this session to prevent importing duplicates within the same batch
    session_hashes = [] # List of (hash_obj, name)

    for category_dir in source_dir.iterdir():
        if not category_dir.is_dir() or category_dir.name.startswith("."):
            continue
        
        category_name = strip_id_prefix(category_dir.name)
        source_path, format_type = find_image_source(category_dir)
        
        if not source_path:
            console.print(f"[yellow]Skipping {category_dir.name}: no svg or png folder found[/yellow]")
            continue
            
        console.print(f"\n[cyan]{category_name}[/cyan] ({format_type.upper()})")
        
        # Prepare category data
        if category_name not in categories_data:
            categories_data[category_name] = []
            
        # Create category folder in assets
        category_folder = ASSETS_PATH / category_name
        category_folder.mkdir(exist_ok=True)
        
        image_extensions = [".svg"] if format_type == "svg" else [".png"]
        images = [f for f in source_path.iterdir() if f.suffix.lower() in image_extensions]
        
        processed_count = 0
        skipped_count = 0
        
        for image_file in track(images, description=f"Processing {category_name}"):
            # Compute hash
            img_hash_str = compute_image_hash(image_file)
            if not img_hash_str:
                console.print(f"[red]Failed to hash {image_file.name}[/red]")
                continue
                
            img_hash = imagehash.hex_to_hash(img_hash_str)
            
            # Check for duplicates
            is_duplicate = False
            
            # Check against global existing
            for exist_h, exist_name in existing_hashes:
                if (img_hash - exist_h) < threshold:
                    console.print(f"  [yellow]Duplicate:[/yellow] {image_file.name} similar to existing {exist_name}")
                    is_duplicate = True
                    break
            
            if is_duplicate:
                skipped_count += 1
                continue
                
            # Check against session (processed in this run)
            for sess_h, sess_name in session_hashes:
                if (img_hash - sess_h) < threshold:
                    console.print(f"  [yellow]Duplicate (in batch):[/yellow] {image_file.name} similar to {sess_name}")
                    is_duplicate = True
                    break
            
            if is_duplicate:
                skipped_count += 1
                continue
                
            # Unique - Proceed to import
            stem = image_file.stem.lower().replace(" ", "-")
            new_sticker_name = f"{stem}_{img_hash_str}"
            
            create_imageset(new_sticker_name, image_file, category_folder, format_type)
            
            # Add to data structure
            categories_data[category_name].append({
                "name": new_sticker_name,
                "labels": [] # Empty for now, to be filled by label-stickers
            })
            
            # Add to session hashes
            session_hashes.append((img_hash, new_sticker_name))
            processed_count += 1
            
        console.print(f"[green]✓[/green] Imported {processed_count} stickers (Skipped {skipped_count} duplicates)")


def save_swift_file(categories: Dict[str, List[Dict]]):
    """Save categories to CustomStickerCategory.swift."""
    if not SWIFT_FILE.exists():
        console.print(f"[red]Error: {SWIFT_FILE} not found[/red]")
        return

    content = SWIFT_FILE.read_text()
    pattern = r"(static let allCategories: \[CustomStickerCategory\] = \[)(.*?)(\n    \])"
    match = re.search(pattern, content, re.DOTALL)
    
    if not match:
        console.print("[red]Error: Could not find allCategories array in Swift file[/red]")
        return

    new_entries = []
    for cat_name in sorted(categories.keys()):
        stickers = categories[cat_name]
        # Deduplicate by name just in case
        unique_stickers = {s["name"]: s for s in stickers}.values()
        
        sticker_objs = []
        for s in unique_stickers:
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
    threshold: int = typer.Option(10, help="Hamming distance threshold for duplicate detection")
):
    """Import stickers with duplicate detection via pHash."""
    if not source_dir.exists():
        console.print(f"[red]Error: {source_dir} does not exist[/red]")
        raise typer.Exit(1)
    
    console.print(f"[bold]Importing stickers from:[/bold] {source_dir}")
    ASSETS_PATH.mkdir(parents=True, exist_ok=True)
    
    # 1. Load existing stickers and their hashes
    console.print("Loading existing stickers...")
    existing_categories = parse_swift_file()
    existing_hashes = [] # List of (hash_obj, name)
    
    count_existing = 0
    
    # Pre-calculate/load hashes for all existing stickers to ensure we don't duplicate legacy ones
    all_existing_stickers = []
    for cat, stickers in existing_categories.items():
        for s in stickers:
            all_existing_stickers.append((cat, s))

    for cat_name, sticker in track(all_existing_stickers, description="Indexing existing stickers"):
        s_name = sticker["name"]
        h_str = extract_hash_from_name(s_name)
        
        if h_str:
            # Has hash in name
            try:
                existing_hashes.append((imagehash.hex_to_hash(h_str), s_name))
            except:
                pass
        else:
            # Legacy sticker or no hash in name - Checking file to compute hash
            # Try to find the image file
            imageset_path = ASSETS_PATH / cat_name / f"{s_name}.imageset"
            if imageset_path.exists():
                possible_files = list(imageset_path.glob("image.*"))
                if possible_files:
                    computed = compute_image_hash(possible_files[0])
                    if computed:
                        try:
                            existing_hashes.append((imagehash.hex_to_hash(computed), s_name))
                        except:
                            pass
        count_existing += 1
            
    console.print(f"Found {count_existing} existing stickers ({len(existing_hashes)} hashed).")

    # 2. Process new stickers
    categories_data = existing_categories.copy()
    
    # Track new hashes in this session to prevent importing duplicates within the same batch
    session_hashes = [] # List of (hash_obj, name)

    for category_dir in source_dir.iterdir():
        if not category_dir.is_dir() or category_dir.name.startswith("."):
            continue
        
        category_name = strip_id_prefix(category_dir.name)
        source_path, format_type = find_image_source(category_dir)
        
        if not source_path:
            console.print(f"[yellow]Skipping {category_dir.name}: no svg or png folder found[/yellow]")
            continue
            
        console.print(f"\n[cyan]{category_name}[/cyan] ({format_type.upper()})")
        
        # Prepare category data
        if category_name not in categories_data:
            categories_data[category_name] = []
            
        # Create category folder in assets
        category_folder = ASSETS_PATH / category_name
        category_folder.mkdir(exist_ok=True)
        
        image_extensions = [".svg"] if format_type == "svg" else [".png"]
        images = [f for f in source_path.iterdir() if f.suffix.lower() in image_extensions]
        
        processed_count = 0
        skipped_count = 0
        failed_stickers = []
        
        for image_file in track(images, description=f"Processing {category_name}"):
            # Compute hash
            img_hash_str = compute_image_hash(image_file)
            if not img_hash_str:
                console.print(f"[red]Failed to hash {image_file.name}[/red]")
                failed_stickers.append(image_file.name)
                continue
                
            img_hash = imagehash.hex_to_hash(img_hash_str)
            
            # Check for duplicates
            is_duplicate = False
            
            # Check against global existing
            for exist_h, exist_name in existing_hashes:
                if (img_hash - exist_h) < threshold:
                    console.print(f"  [yellow]Duplicate:[/yellow] {image_file.name} similar to existing {exist_name}")
                    is_duplicate = True
                    break
            
            if is_duplicate:
                skipped_count += 1
                continue
                
            # Check against session (processed in this run)
            for sess_h, sess_name in session_hashes:
                if (img_hash - sess_h) < threshold:
                    console.print(f"  [yellow]Duplicate (in batch):[/yellow] {image_file.name} similar to {sess_name}")
                    is_duplicate = True
                    break
            
            if is_duplicate:
                skipped_count += 1
                continue
                
            # Unique - Proceed to import
            stem = image_file.stem.lower().replace(" ", "-")
            new_sticker_name = f"{stem}_{img_hash_str}"
            
            create_imageset(new_sticker_name, image_file, category_folder, format_type)
            
            # Add to data structure
            categories_data[category_name].append({
                "name": new_sticker_name,
                "labels": [] # Empty for now, to be filled by label-stickers
            })
            
            # Add to session hashes
            session_hashes.append((img_hash, new_sticker_name))
            processed_count += 1
            
        console.print(f"[green]✓[/green] Imported {processed_count} stickers (Skipped {skipped_count} duplicates)")
        if failed_stickers:
            console.print(f"[red]Failed to import {len(failed_stickers)} stickers in {category_name}:[/red]")
            for f in failed_stickers:
                console.print(f"  - {f}")

    # 3. Update Swift File
    if session_hashes:
        console.print("\n[bold]Updating Swift code...[/bold]")
        save_swift_file(categories_data)


@app.command()
def label_stickers(
    gemini_key: Optional[str] = typer.Option(None, "--gemini-key", help="Gemini API key")
):
    """Scan for stickers with missing labels and generate them using Gemini."""
    
    api_key = gemini_key or os.getenv("GEMINI_API_KEY")
    if not api_key:
        console.print("[red]Error: Gemini API key required. Set GEMINI_API_KEY or use --gemini-key[/red]")
        raise typer.Exit(1)
        
    console.print("[bold]Scanning for missing labels...[/bold]")
    categories = parse_swift_file()
    
    total_labeled = 0
    quota_exceeded = False
    
    updates_made = False
    
    for cat_name, stickers in categories.items():
        if quota_exceeded:
            break
            
        cat_updates = False
        
        # Identify stickers to label
        to_label = [s for s in stickers if not s["labels"]]
        
        if not to_label:
            continue
            
        console.print(f"Category: [cyan]{cat_name}[/cyan] ({len(to_label)} missing labels)")
        
        for sticker in track(to_label, description=f"Labeling {cat_name}"):
            sticker_name = sticker["name"]
            
            # Find image file
            # We don't know if it's svg or png, or where exactly it is in terms of original file,
            # but we know it's in Assets.xcassets/Stickers/<cat_name>/<sticker_name>.imageset/
            imageset_path = ASSETS_PATH / cat_name / f"{sticker_name}.imageset"
            
            if not imageset_path.exists():
                console.print(f"  [yellow]Warning: Imageset not found for {sticker_name}[/yellow]")
                continue
            
            # Look for image.png or image.svg
            possible_files = list(imageset_path.glob("image.*"))
            if not possible_files:
                 console.print(f"  [yellow]Warning: No image file found in {imageset_path}[/yellow]")
                 continue
                 
            image_path = possible_files[0]
            
            # Generate labels
            labels = generate_label_for_image(image_path, api_key)
            
            if labels and labels[0] == "__QUOTA_EXCEEDED__":
                quota_exceeded = True
                break
                
            if labels:
                sticker["labels"] = labels
                total_labeled += 1
                cat_updates = True
                updates_made = True
                console.print(f"  [green]Labeled {sticker_name}:[/green] {', '.join(labels[:3])}...")
        
    if updates_made:
        console.print("\n[bold]Saving changes to Swift file...[/bold]")
        save_swift_file(categories)
    else:
        console.print("[yellow]No updates made.[/yellow]")


@app.command()
def migrate_stickers(
    dry_run: bool = typer.Option(False, "--dry-run", help="Preview changes without applying them")
):
    """Migrate existing stickers to use pHash naming convention ({name}_{hash})."""
    console.print("[bold]Migrating existing stickers...[/bold]")
    categories = parse_swift_file()
    
    migrated_count = 0
    skipped_count = 0
    failed_count = 0
    failed_report = [] # List of (category, sticker_name, reason)
    
    updates_made = False
    
    for cat_name, stickers in categories.items():
        console.print(f"\nScanning category: [cyan]{cat_name}[/cyan]")
        
        for sticker in track(stickers, description=f"Processing {cat_name}"):
            old_name = sticker["name"]
            
            # Check if likely already has hash (simple heuristic: ends with 16 hex chars)
            if extract_hash_from_name(old_name):
                # console.print(f"  [dim]Skipping {old_name} (already hashed)[/dim]")
                skipped_count += 1
                continue
            
            # Find imageset
            imageset_path = ASSETS_PATH / cat_name / f"{old_name}.imageset"
            if not imageset_path.exists():
                console.print(f"  [red]Error: Imageset not found for {old_name}[/red]")
                failed_count += 1
                failed_report.append((cat_name, old_name, "Imageset not found"))
                continue
                
            # Find image file to hash
            possible_files = list(imageset_path.glob("image.*"))
            if not possible_files:
                 # Check for other files if image.* doesn't exist (legacy might differ)
                 # Filter out Contents.json
                 files = [f for f in imageset_path.iterdir() if f.is_file() and f.name != "Contents.json" and not f.name.startswith(".")]
                 if not files:
                     console.print(f"  [red]Error: No image file found in {imageset_path}[/red]")
                     failed_count += 1
                     failed_report.append((cat_name, old_name, "No image file found"))
                     continue
                 image_path = files[0]
            else:
                image_path = possible_files[0]
            
            # Compute Hash
            hash_str = compute_image_hash(image_path)
            if not hash_str:
                console.print(f"  [red]Error: Could not compute hash for {old_name}[/red]")
                failed_count += 1
                failed_report.append((cat_name, old_name, "Hash computation failed"))
                continue
                
            new_name = f"{old_name}_{hash_str}"
            new_imageset_path = ASSETS_PATH / cat_name / f"{new_name}.imageset"
            
            if new_imageset_path.exists() and new_imageset_path != imageset_path:
                 console.print(f"  [yellow]Warning: Target {new_name} already exists. Skipping rename.[/yellow]")
                 # We might still want to update the swift ref if it points to the old one?
                 # But safer to skip to avoid conflicts
                 failed_count += 1
                 failed_report.append((cat_name, old_name, "Target name collision"))
                 continue

            if dry_run:
                console.print(f"  [dim]Would rename {old_name} -> {new_name}[/dim]")
                migrated_count += 1
            else:
                try:
                    # Rename directory
                    imageset_path.rename(new_imageset_path)
                    
                    # Update sticker object in memory
                    sticker["name"] = new_name
                    updates_made = True
                    migrated_count += 1
                    # console.print(f"  [green]Migrated {old_name} -> {new_name}[/green]")
                except Exception as e:
                    console.print(f"  [red]Error renaming {old_name}: {e}[/red]")
                    failed_count += 1
                    failed_report.append((cat_name, old_name, f"Rename error: {e}"))

    console.print(f"\n[bold]Migration Summary:[/bold]")
    console.print(f"  Migrated: {migrated_count}")
    console.print(f"  Skipped (already hashed): {skipped_count}")
    console.print(f"  Failed: {failed_count}")
    
    if failed_report:
        console.print(f"\n[red][bold]Failed Items ({len(failed_report)}):[/bold][/red]")
        for cat, name, reason in failed_report:
            console.print(f"  - [{cat}] {name}: {reason}")

    if updates_made and not dry_run:
        console.print("\n[bold]Saving changes to Swift file...[/bold]")
        save_swift_file(categories)
    elif dry_run:
        console.print("\n[yellow]Dry run completed. No changes saved.[/yellow]")
    else:
        console.print("\n[yellow]No changes needed.[/yellow]")


if __name__ == "__main__":
    app()
