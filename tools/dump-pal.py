#!/usr/bin/env python

__version__ = "1.0"

from argparse import ArgumentParser
from PIL import Image

# firmware
CPC_PAL = (
    [0, 0, 0],
    [0, 0, 128],
    [0, 0, 255],
    [128, 0, 0],
    [128, 0, 128],
    [128, 0, 255],
    [255, 0, 0],
    [255, 0, 128],
    [255, 0, 255],
    [0, 128, 0],
    [0, 128, 128],
    [0, 128, 255],
    [128, 128, 0],
    [128, 128, 128],
    [128, 128, 255],
    [255, 128, 0],
    [255, 128, 128],
    [255, 128, 255],
    [0, 255, 0],
    [0, 255, 128],
    [0, 255, 255],
    [128, 255, 0],
    [128, 255, 128],
    [128, 255, 255],
    [255, 255, 0],
    [255, 255, 128],
    [255, 255, 255],
        )

# hardware
CPC_PAL_HW = (
    0x54, 0x44, 0x55, 0x5c, 0x58, 0x5d, 0x4c, 0x45, 0x4d,
    0x56, 0x46, 0x57, 0x5e, 0x40, 0x5f, 0x4e, 0x47, 0x4f,
    0x52, 0x42, 0x53, 0x5a, 0x59, 0x5b, 0x4a, 0x43, 0x4b,
        )

def main():

    parser = ArgumentParser(description="PNG to CPC palette (firmware)",
                            epilog="Copyright (C) 2015 Juan J Martinez <jjm@usebox.net>",
                            )

    parser.add_argument("--version", action="version", version="%(prog)s "  + __version__)
    parser.add_argument("--hw", action="store_true", dest="hardware")
    parser.add_argument("image", help="image to convert")
    parser.add_argument("pal_dump", help="filename for the palette dump")

    args = parser.parse_args()

    try:
        image = Image.open(args.image)
    except IOError:
        parser.error("failed to open the image")

    if image.mode != "P":
        parser.error("not an indexed image (no palette)")

    palette = image.getpalette()
    if not palette:
        parser.error("failed to extract the palette (is this an indexed image?)")

    colors = image.getcolors(maxcolors=16)
    if not colors:
        parser.error("failed to extract the palette (color limit is 16)")

    rgb = []
    for _, i in colors:
        c = palette[i * 3:i * 3 + 3]
        if c not in CPC_PAL:
            parser.error("%r not in the CPC palette" % c)
        if c not in rgb:
            rgb.append(c)

    out = [CPC_PAL.index(c) for c in rgb]
    if len(out) < 16:
        out.extend([i for i in range(16 - len(out))])

    if args.hardware:
        out = [CPC_PAL_HW[c] for c in out]

    with open(args.pal_dump, "wb") as fd:
        fd.write(bytearray(out))

if __name__ == "__main__":
    main()

