#!/usr/bin/env python3
"""Frames the raw renders and builds the README and pub.dev images.

    flutter test tool/screenshots/generate_test.dart   # renders doc/readme/raw
    python3 tool/screenshots/frame.py                  # frames + composites

Needs Pillow (`pip install pillow`). Uses Roboto from the Flutter SDK for the
status-bar clock, so run it with FLUTTER_ROOT set or `flutter` on PATH.

The device frame is a generic phone -- rounded bezel and a centred punch-hole
camera -- rather than a replica of any particular manufacturer's hardware.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "doc/readme/raw"
OUT = ROOT / "doc/readme"
PUB = ROOT / "screenshots"

SCALE = 3  # raw renders are 3x
SCREEN_RADIUS = 52 * SCALE
BEZEL = 13 * SCALE
BEZEL_RADIUS = SCREEN_RADIUS + BEZEL


def flutter_root() -> Path:
    env = os.environ.get("FLUTTER_ROOT")
    if env:
        return Path(env)
    flutter = shutil.which("flutter")
    if not flutter:
        raise SystemExit("Set FLUTTER_ROOT or put `flutter` on PATH (needed for Roboto).")
    return Path(os.path.realpath(flutter)).parents[1]


FONTS = flutter_root() / "bin/cache/artifacts/material_fonts"


def font(weight: str, size: float) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS / f"Roboto-{weight}.ttf"), int(size))


# --- status bar --------------------------------------------------------------


def draw_status_bar(img: Image.Image, dark: bool) -> None:
    d = ImageDraw.Draw(img)
    ink = (255, 255, 255, 255) if dark else (16, 18, 22, 255)
    w = img.width
    cy = 27 * SCALE  # vertical centre of the 54pt status bar

    clock = font("Medium", 17 * SCALE)
    d.text((34 * SCALE, cy), "9:41", font=clock, fill=ink, anchor="lm")

    right = w - 30 * SCALE

    # Battery: body, fill and nub.
    bw, bh = 25 * SCALE, 12 * SCALE
    bx0, by0 = right - bw, cy - bh // 2
    d.rounded_rectangle(
        (bx0, by0, bx0 + bw, by0 + bh), radius=4 * SCALE, outline=ink, width=int(1.2 * SCALE)
    )
    pad = int(2 * SCALE)
    d.rounded_rectangle(
        (bx0 + pad, by0 + pad, bx0 + int(bw * 0.78), by0 + bh - pad),
        radius=2 * SCALE,
        fill=ink,
    )
    d.rounded_rectangle(
        (bx0 + bw + SCALE, cy - 2 * SCALE, bx0 + bw + int(2.6 * SCALE), cy + 2 * SCALE),
        radius=SCALE,
        fill=ink,
    )

    # Wi-Fi: three arcs and a dot.
    wx = bx0 - 17 * SCALE
    wy = cy + 5 * SCALE
    for i, r in enumerate((11, 7.5, 4)):
        rr = r * SCALE
        d.arc((wx - rr, wy - rr, wx + rr, wy + rr), 225, 315, fill=ink, width=int(2 * SCALE))
    d.ellipse((wx - 1.6 * SCALE, wy - 1.6 * SCALE, wx + 1.6 * SCALE, wy + 1.6 * SCALE), fill=ink)

    # Cellular: four ascending bars.
    sx = wx - 32 * SCALE
    for i in range(4):
        bar_h = (4 + i * 2.6) * SCALE
        x0 = sx + i * 5 * SCALE
        d.rounded_rectangle(
            (x0, cy + 6 * SCALE - bar_h, x0 + 3.2 * SCALE, cy + 6 * SCALE),
            radius=SCALE,
            fill=ink,
        )


def draw_home_indicator(img: Image.Image, dark: bool) -> None:
    d = ImageDraw.Draw(img)
    ink = (255, 255, 255, 235) if dark else (16, 18, 22, 225)
    w, h = img.size
    iw, ih = 134 * SCALE, 5 * SCALE
    y1 = h - 8 * SCALE
    d.rounded_rectangle(
        ((w - iw) // 2, y1 - ih, (w + iw) // 2, y1), radius=ih // 2, fill=ink
    )


# --- device frame --------------------------------------------------------------


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def frame(screen: Image.Image) -> Image.Image:
    sw, sh = screen.size
    fw, fh = sw + BEZEL * 2, sh + BEZEL * 2
    device = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    d = ImageDraw.Draw(device)

    # Outer rim, then the bezel, for a hint of depth.
    d.rounded_rectangle((0, 0, fw - 1, fh - 1), radius=BEZEL_RADIUS, fill=(58, 60, 66, 255))
    inset = int(1.5 * SCALE)
    d.rounded_rectangle(
        (inset, inset, fw - 1 - inset, fh - 1 - inset),
        radius=BEZEL_RADIUS - inset,
        fill=(20, 21, 24, 255),
    )

    device.paste(screen, (BEZEL, BEZEL), rounded_mask(screen.size, SCREEN_RADIUS))

    # Centred punch-hole camera over the status bar.
    cx, cy, r = fw // 2, BEZEL + 18 * SCALE, int(5.5 * SCALE)
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(8, 8, 10, 255))
    d.ellipse((cx - r // 2.6, cy - r // 2.6, cx + r // 2.6, cy + r // 2.6), fill=(28, 34, 48, 255))
    return device


def with_shadow(device: Image.Image, blur: int = 40, offset: int = 30) -> Image.Image:
    pad = blur * 3
    canvas = Image.new("RGBA", (device.width + pad * 2, device.height + pad * 2), (0, 0, 0, 0))
    shadow = Image.new("RGBA", device.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (0, 0, device.width - 1, device.height - 1), radius=BEZEL_RADIUS, fill=(15, 23, 42, 70)
    )
    canvas.paste(shadow, (pad, pad + offset), shadow)
    canvas = canvas.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(device, (pad, pad))
    return canvas


# --- composites -----------------------------------------------------------------


def gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    w, h = size
    base = Image.new("RGB", (1, h))
    for y in range(h):
        t = y / max(1, h - 1)
        base.putpixel((0, y), tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    return base.resize((w, h)).convert("RGBA")


def hero(framed: dict[str, Image.Image], ids: list[str], path: Path) -> None:
    phone_h = 1500
    phones = []
    for i in ids:
        f = framed[i]
        scaled = f.resize((int(f.width * phone_h / f.height), phone_h), Image.LANCZOS)
        phones.append(with_shadow(scaled, blur=34, offset=26))

    gap = -40
    width = sum(p.width for p in phones) + gap * (len(phones) - 1)
    canvas = gradient((width, phones[0].height), (236, 242, 255), (247, 249, 252))
    x = 0
    for p in phones:
        canvas.alpha_composite(p, (x, 0))
        x += p.width + gap
    canvas = canvas.resize((2000, int(canvas.height * 2000 / canvas.width)), Image.LANCZOS)
    canvas.convert("RGB").save(path, "WEBP", quality=90, method=6)


def save_phone(img: Image.Image, path: Path, width: int, quality: int = 90) -> None:
    out = img.resize((width, int(img.height * width / img.width)), Image.LANCZOS)
    path.parent.mkdir(parents=True, exist_ok=True)
    # Alpha is kept so the rounded corners sit cleanly on any page background.
    out.save(path, "WEBP", quality=quality, method=6, exact=False)


def main() -> None:
    manifest = json.loads((RAW / "manifest.json").read_text())
    framed: dict[str, Image.Image] = {}

    # One set of phone images serves both the README gallery and the pub.dev
    # gallery (`screenshots:` in pubspec.yaml). They ship inside the package
    # archive, so they are kept deliberately small.
    for scene, meta in manifest.items():
        raw = Image.open(RAW / f"{scene}.png").convert("RGBA")
        draw_status_bar(raw, meta["dark"])
        draw_home_indicator(raw, meta["dark"])
        framed[scene] = frame(raw)
        save_phone(framed[scene], PUB / f"{scene}.webp", width=720, quality=86)

    # README only; excluded from the archive by .pubignore.
    hero(framed, ["search", "center_pin", "dark"], OUT / "hero.webp")

    for p in sorted([*OUT.glob("*.webp"), *PUB.glob("*.webp")]):
        print(f"{p.relative_to(ROOT)}  {p.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
