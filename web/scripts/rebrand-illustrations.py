"""Recolour the downloaded unDraw SVGs onto the StrongBox palette.

unDraw ships every illustration in its own house palette (indigo accent
#6c63ff over slate greys). Left alone the art reads as stock; remapped, it
sits inside the navy/blue brand as if it were drawn for it. Skin tones are
deliberately left untouched — recolouring people is never the goal.

`MAP` carries two generations of keys: unDraw's own hexes, and the retired
amber-era StrongBox hexes. The second set means this script can be re-run
over the SVGs already in `public/illustrations/` to migrate them in place,
without a round trip to the CDN — and a fresh `fetch-illustrations.sh` pull
still lands on the current palette, because both generations resolve to the
same blue values.
"""
import pathlib, re, sys

MAP = {
    # ── unDraw source palette ──
    # accent -> StrongBox azure
    "#6c63ff": "#1d6fe0",
    "#514e7f": "#1557b5",
    # slate structure -> navy family
    "#3f3d56": "#0f2a52",
    "#2f2e41": "#0a1a33",
    "#2f2e43": "#0a1a33",
    "#090814": "#0a1a33",
    "#231f20": "#0a1a33",
    "#65617d": "#1b3e6f",
    "#464353": "#1b3e6f",
    "#454b69": "#1b3e6f",
    # neutrals -> brand surfaces
    "#a7adb8": "#5ea6f5",
    "#b6b3c5": "#c3d2e6",
    "#d6d6e3": "#c3d2e6",
    "#d1d3d4": "#c3d2e6",
    "#cbcbcb": "#c3d2e6",
    "#ccc":    "#c3d2e6",
    "#dfe6f5": "#e8f1fd",
    "#e5e5e5": "#e8f1fd",
    "#e6e6e6": "#e8f1fd",
    "#f0f0f0": "#f4f8fd",
    "#f1f1f1": "#f4f8fd",
    "#f2f2f2": "#f4f8fd",
    # Not a skin tone despite living in unDraw's pink range: this one appears
    # only as a decorative accent blob (in `map-location`), where leaving it
    # pink drops a single off-brand red into an otherwise blue drawing.
    "#ff6884": "#1d6fe0",

    # ── retired amber-era StrongBox palette, for in-place migration ──
    "#feae2c": "#1d6fe0",
    "#ba7900": "#1557b5",
    "#ffddb4": "#e8f1fd",
    "#ffb954": "#5ea6f5",
    "#1a2b4a": "#0f2a52",
    "#031634": "#0a1a33",
    "#3d4f6d": "#1b3e6f",
    "#8293b7": "#5ea6f5",
    "#c5c6cf": "#c3d2e6",
    "#e4e1ee": "#e8f1fd",
    "#efecf9": "#e8f1fd",
    "#f5f2ff": "#f4f8fd",
}
# Skin, lips and pure white stay as drawn.
KEEP = {"#fff", "#ffffff", "#ffb6b6", "#ffb8b8", "#fbbebe", "#a0616a",
        "#a1616a", "#ed9da0", "#f8a8ab", "#e49497"} | set(MAP.values())

HEX = re.compile(r"#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b")

def main(folder: str) -> None:
    unmapped: set[str] = set()
    for path in sorted(pathlib.Path(folder).glob("*.svg")):
        text = original = path.read_text(encoding="utf-8")

        def sub(m: re.Match[str]) -> str:
            raw = m.group(0)
            key = raw.lower()
            if key in KEEP:
                return raw
            if key in MAP:
                return MAP[key]
            unmapped.add(key)
            return raw

        text = HEX.sub(sub, text)
        # Drop the fixed width/height on the root <svg> so the viewBox alone
        # drives scaling and the wrapper element decides the rendered size.
        # Scoped to the opening tag and matched by name rather than by count:
        # a bare `count=2` walks into the artwork on a second run and starts
        # stripping the dimensions off <rect> elements, silently wrecking the
        # drawing. This form is safe to re-run over an already-processed file.
        def strip_root(m: re.Match[str]) -> str:
            return re.sub(r'\s(?:width|height)="[\d.]+"', "", m.group(0))

        text = re.sub(r"<svg\b[^>]*>", strip_root, text, count=1)
        if text != original:
            path.write_text(text, encoding="utf-8")
            print(f"rebranded {path.name}")

    if unmapped:
        print("\nleft untouched (not in map or KEEP):", ", ".join(sorted(unmapped)))

main(sys.argv[1])
