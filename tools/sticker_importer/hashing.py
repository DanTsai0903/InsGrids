
import subprocess
import shutil
import tempfile
import os
from pathlib import Path
from typing import Optional

import imagehash
from PIL import Image

def compute_image_hash(image_path: Path) -> Optional[str]:
    """
    Compute Perceptual Hash (pHash) for an image (SVG or PNG).
    For SVGs, converts to PNG using qlmanage first.
    Returns the hex string of the hash.
    """
    if not image_path.exists():
        return None

    try:
        # Check if it's an SVG
        if image_path.suffix.lower() == ".svg":
            with tempfile.TemporaryDirectory() as tmp_dir:
                tmp_path = Path(tmp_dir)
                
                # Use qlmanage to convert SVG to PNG
                # Retry logic for qlmanage which can be flaky
                max_retries = 3
                success = False
                
                for attempt in range(max_retries):
                    try:
                        cmd = [
                            "qlmanage", "-t", "-s", "512", 
                            "-o", str(tmp_path), 
                            str(image_path)
                        ]
                        
                        subprocess.run(
                            cmd, 
                            check=True, 
                            stdout=subprocess.DEVNULL, 
                            stderr=subprocess.DEVNULL
                        )
                        success = True
                        break
                    except subprocess.CalledProcessError:
                         if attempt < max_retries - 1:
                             continue
                
                if not success:
                    print(f"Warning: qlmanage failed for {image_path} after {max_retries} attempts")
                    return None

                # qlmanage usually creates <filename>.svg.png or similar in the output dir
                # Let's find the generated png file
                generated_png = next(tmp_path.glob("*.png"), None)
                
                if not generated_png:
                    # Fallback: try looking for the exact filename + .png or similar
                    # Sometimes qlmanage is tricky. If this fails, we might just return None
                    print(f"Warning: qlmanage failed to generate PNG for {image_path}")
                    return None
                    
                image = Image.open(generated_png)
                img_hash = imagehash.phash(image)
                return str(img_hash)
        
        else:
            # Assume raster image supported by PIL
            image = Image.open(image_path)
            img_hash = imagehash.phash(image)
            return str(img_hash)
            
    except Exception as e:
        print(f"Error computing hash for {image_path}: {e}")
        return None
