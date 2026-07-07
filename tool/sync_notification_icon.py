"""Build Android notification icons from assets/images/notification_icon.png.

- ic_notification.png       → tiny white mask (status bar only)
- ic_notification_large.png → full-color #DFF1FF avatar (notification UI)

Run after updating the custom icon:
  python tool/sync_notification_icon.py
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "images" / "notification_icon.png"
RES = ROOT / "android" / "app" / "src" / "main" / "res"

NOTIFICATION_BG = (223, 241, 255, 255)  # #DFF1FF

SMALL_SIZES = {
    "drawable-mdpi": 24,
    "drawable-hdpi": 36,
    "drawable-xhdpi": 48,
    "drawable-xxhdpi": 72,
    "drawable-xxxhdpi": 96,
}
LARGE_SIZES = {
    "drawable-mdpi": 48,
    "drawable-hdpi": 72,
    "drawable-xhdpi": 96,
    "drawable-xxhdpi": 144,
    "drawable-xxxhdpi": 192,
}


def _prepare_logo(source: Image.Image) -> Image.Image:
    img = source.convert("RGBA")
    w, h = img.size
    px = img.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if r < 45 and g < 45 and b < 45:
                px[x, y] = (0, 0, 0, 0)

    crop_h = int(h * 0.58)
    img = img.crop((0, 0, w, crop_h))
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
    return img


def _paste_scaled(canvas: Image.Image, logo: Image.Image, inset_ratio: float) -> None:
    size = canvas.size[0]
    inset = max(1, int(size * inset_ratio))
    inner = size - (inset * 2)
    lw, lh = logo.size
    scale = min(inner / lw, inner / lh)
    nw, nh = max(1, int(lw * scale)), max(1, int(lh * scale))
    resized = logo.resize((nw, nh), Image.Resampling.LANCZOS)
    ox = (size - nw) // 2
    oy = (size - nh) // 2
    canvas.paste(resized, (ox, oy), resized)


def _build_color_icon(logo: Image.Image, size: int) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    draw.ellipse((0, 0, size - 1, size - 1), fill=NOTIFICATION_BG)
    _paste_scaled(canvas, logo, inset_ratio=0.05)
    return canvas


def _build_status_icon(logo: Image.Image, size: int) -> Image.Image:
    """Bold white mask for status bar — not shown in messaging avatar."""
    mask = Image.new("RGBA", logo.size, (0, 0, 0, 0))
    src = logo.load()
    dst = mask.load()
    for y in range(logo.size[1]):
        for x in range(logo.size[0]):
            _, _, _, a = src[x, y]
            if a > 24:
                dst[x, y] = (255, 255, 255, a)
    mask = mask.filter(ImageFilter.MaxFilter(5))

    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    _paste_scaled(canvas, mask, inset_ratio=0.04)
    return canvas


def main() -> None:
    if not SRC.is_file():
        raise SystemExit(f"Custom icon not found: {SRC}")

    logo = _prepare_logo(Image.open(SRC))
    print(f"Using {SRC} (character {logo.size[0]}x{logo.size[1]})")

    for folder, size in SMALL_SIZES.items():
        out_dir = RES / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        _build_status_icon(logo, size).save(out_dir / "ic_notification.png")

    for folder, size in LARGE_SIZES.items():
        out_dir = RES / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        _build_color_icon(logo, size).save(out_dir / "ic_notification_large.png")

    drawable = RES / "drawable"
    drawable.mkdir(parents=True, exist_ok=True)
    _build_status_icon(logo, 96).save(drawable / "ic_notification.png")
    _build_color_icon(logo, 192).save(drawable / "ic_notification_large.png")

    print("Synced status + color notification icons.")


if __name__ == "__main__":
    main()
