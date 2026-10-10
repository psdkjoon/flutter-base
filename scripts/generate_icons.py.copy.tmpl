#!/usr/bin/env python3
import argparse
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
ICONS = ROOT / "assets" / "icons"
VARIANTS = ("mocha", "latte")
ANDROID_SIZES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
ICO_SIZES = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
MASTER = 1024


def rasterize(svg: pathlib.Path, out: pathlib.Path) -> None:
    size = str(MASTER)
    if shutil.which("rsvg-convert"):
        cmd = ["rsvg-convert", "-w", size, "-h", size, "-o", str(out), str(svg)]
    elif shutil.which("inkscape"):
        cmd = ["inkscape", str(svg), "-w", size, "-h", size, "-o", str(out)]
    elif shutil.which("magick"):
        cmd = ["magick", "-background", "none", "-density", "1200", str(svg),
               "-resize", f"{size}x{size}", str(out)]
    else:
        try:
            import cairosvg
        except ImportError:
            sys.exit("Install one of: librsvg (rsvg-convert), inkscape, imagemagick, python-cairosvg")
        cairosvg.svg2png(url=str(svg), write_to=str(out),
                         output_width=MASTER, output_height=MASTER)
        return
    subprocess.run(cmd, check=True)


def save(image: Image.Image, size: int, path: pathlib.Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.resize((size, size), Image.LANCZOS).save(path, optimize=True)
    print(f"  {path.relative_to(ROOT)}")


def glyph_path(svg: pathlib.Path) -> str:
    match = re.search(r'<path id="glyph" d="([^"]+)"', svg.read_text(encoding="utf-8"))
    if match is None:
        sys.exit(f'{svg.name} needs a <path id="glyph" d="..."/> element')
    return match.group(1)


def write_tile_drawable(svg: pathlib.Path, res: pathlib.Path) -> None:
    out = res / "drawable" / "ic_tile.xml"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
        '    android:width="24dp"\n'
        '    android:height="24dp"\n'
        '    android:viewportWidth="24"\n'
        '    android:viewportHeight="24">\n'
        '    <path\n'
        '        android:fillColor="#FFFFFFFF"\n'
        f'        android:pathData="{glyph_path(svg)}" />\n'
        '</vector>\n',
        encoding="utf-8",
    )
    print(f"  {out.relative_to(ROOT)}")


def main() -> int:
    argparse.ArgumentParser(
        description="Builds every PNG, ICO and Android tile icon from "
        "assets/icons/icon_mocha.svg and icon_latte.svg."
    ).parse_args()

    masters = {}
    with tempfile.TemporaryDirectory() as tmp:
        for variant in VARIANTS:
            svg = ICONS / f"icon_{variant}.svg"
            png = pathlib.Path(tmp) / f"{variant}.png"
            rasterize(svg, png)
            masters[variant] = Image.open(png).convert("RGBA")

    for variant, image in masters.items():
        save(image, MASTER, ICONS / f"logo_{variant}.png")
        save(image, 256, ICONS / f"tray_{variant}.png")

    linux = ROOT / "linux"
    if linux.is_dir():
        save(masters["mocha"], 256, linux / "icon.png")

    res = ROOT / "android" / "app" / "src" / "main" / "res"
    if res.is_dir():
        for density, size in ANDROID_SIZES.items():
            folder = res / f"mipmap-{density}"
            save(masters["mocha"], size, folder / "ic_launcher.png")
            for variant, image in masters.items():
                save(image, size, folder / f"ic_launcher_{variant}.png")
        write_tile_drawable(ICONS / "icon_mocha.svg", res)

    windows = ROOT / "windows" / "runner" / "resources"
    if windows.is_dir():
        target = windows / "app_icon.ico"
        masters["mocha"].save(target, format="ICO", sizes=ICO_SIZES)
        print(f"  {target.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
