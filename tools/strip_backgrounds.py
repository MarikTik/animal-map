#!/usr/bin/env python3
"""Remove white/gray backgrounds from marker PNGs.

For each PNG in assets/markers/, converts non-colorful pixels
(low saturation, high lightness) to transparent. Overwrites
the originals.

Requires: pip install Pillow
"""

import sys
from pathlib import Path

from PIL import Image


def should_remove(r: int, g: int, b: int, a: int) -> bool:
    """Return True if the pixel looks like a white/gray background."""
    if a == 0:
        return False  # already transparent

    # Saturation: how "colorful" the pixel is.
    # Low saturation = gray/white/black.
    max_c = max(r, g, b)
    min_c = min(r, g, b)
    chroma = max_c - min_c

    # Lightness (0–255 scale)
    lightness = (max_c + min_c) / 2

    # Remove if:
    #  - very low saturation (gray/white) AND reasonably bright
    #  - pure white or near-white
    if chroma < 35 and lightness > 160:
        return True

    # Also catch very bright near-white pixels even with slight tint
    if lightness > 230 and chroma < 50:
        return True

    return False


def process_image(path: Path) -> None:
    img = Image.open(path).convert("RGBA")
    pixels = img.load()
    w, h = img.size
    removed = 0

    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if should_remove(r, g, b, a):
                pixels[x, y] = (0, 0, 0, 0)
                removed += 1

    img.save(path)
    total = w * h
    pct = removed / total * 100
    print(f"  {path.name}: removed {removed}/{total} pixels ({pct:.1f}%)")


def main() -> None:
    markers_dir = Path(__file__).resolve().parent / "assets" / "markers"
    pngs = sorted(markers_dir.glob("*.png"))

    if not pngs:
        print(f"No PNGs found in {markers_dir}")
        sys.exit(1)

    print(f"Processing {len(pngs)} icons in {markers_dir}\n")
    for png in pngs:
        process_image(png)

    print("\nDone. Check the results and adjust thresholds if needed.")


if __name__ == "__main__":
    main()
