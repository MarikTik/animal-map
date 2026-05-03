#!/usr/bin/env python3
"""Resize marker PNGs to 168x168 px (2x the 84 px max display size).

Requires Pillow: pip install pillow

Usage:
    python3 tools/resize_markers.py
"""

from pathlib import Path
from PIL import Image

TARGET = (168, 168)
MARKERS_DIR = Path(__file__).parent.parent / "assets" / "markers"


def resize_marker(path: Path) -> None:
    with Image.open(path) as img:
        original = img.size
        if original == TARGET:
            print(f"  skip  {path.name} (already {TARGET[0]}x{TARGET[1]})")
            return
        resized = img.resize(TARGET, Image.LANCZOS)
        resized.save(path, optimize=True)
        print(f"  resize {path.name}: {original[0]}x{original[1]} → {TARGET[0]}x{TARGET[1]}")


def main() -> None:
    pngs = sorted(MARKERS_DIR.glob("*.png"))
    if not pngs:
        print(f"No PNGs found in {MARKERS_DIR}")
        return
    print(f"Resizing {len(pngs)} marker(s) in {MARKERS_DIR}/")
    for png in pngs:
        resize_marker(png)
    print("Done.")


if __name__ == "__main__":
    main()
