#!/usr/bin/env python

__version__ = "1.0"

import sys
from argparse import ArgumentParser
from PIL import Image

DEF_W = 8
DEF_H = 16

def encode_byte(a, b):
    return (a & 1) << 7 | (b & 1) << 6 \
            | (a & 4) << 3 | (b & 4) << 2 \
            | (a & 2) << 2 | (b & 2) << 1 \
            | (a & 8) >> 2 | (b & 8) >> 3

def main():

    parser = ArgumentParser(description="Image cpcrslib sprite",
                            epilog="Copyright (C) 2015 Juan J Martinez <jjm@usebox.net>",
                            )

    parser.add_argument("--version", action="version", version="%(prog)s "  + __version__)
    parser.add_argument("-i", "--id", dest="id", default="sprite", type=str,
                        help="variable name (default: sprite)")
    parser.add_argument("--width", dest="w", default=DEF_W, type=int,
                        help="sprite width (default: %s)" % DEF_W)
    parser.add_argument("--height", dest="h", default=DEF_H, type=int,
                        help="sprite height (default: %s)" % DEF_H)
    parser.add_argument("--transparent-color", dest="tc", default=None, type=int,
                        help="palette index for the transparent color (default: None)")
    parser.add_argument("-d", "--dimension", dest="dim", action="store_true",
                        help="include the sprite dimensions in the output")
    parser.add_argument("-b", "--binary", dest="binary", action="store_true",
                        help="output binary instead of C code")


    parser.add_argument("image", help="image to convert", nargs="?")

    args = parser.parse_args()

    if not args.image:
        parser.error("required parameter: image")

    if args.tc:
        try:
            args.tc = int(args.tc)
            if args.tc < 0 or args.tc > 15:
                    raise ValueError()
        except ValueError:
            parser.error("--transparent-color expects an integer in [0, 15]")

    try:
        image = Image.open(args.image)
    except IOError:
        parser.error("failed to open the image")

    if image.mode != "P":
        parser.error("not an indexed image (no palette)")

    (w, h) = image.size

    if w % args.w or h % args.h:
        parser.error("%s size is not multiple of the image size" % args.image)

    data = image.getdata()

    out = []
    for x in range(0, w, args.w):
        frame = []
        for y in range(h): # FIXME: different heights!
            if args.dim:
                out.extend([args.w // 2, args.h])
            for i in range(0, args.w, 2):
                a = data[x + i + (y * w)]
                b = data[x + i + 1 + (y * w)]

                if args.tc is not None:
                    mask_a = mask_b = 0
                    if a == args.tc:
                        mask_a = 0xf
                        a = 0
                    if b == args.tc:
                        mask_b = 0xf
                        b = 0
                    frame.append(encode_byte(mask_a, mask_b))

                frame.append(encode_byte(a, b))
        out.append(frame)

    if args.binary:
        for frame in out:
            sys.stdout.write(bytearray(frame))
        return

    frames = len(out)

    data_out = ""
    for block in out:
        if data_out:
            data_out += ",\n"
        data_out += "{"
        for part in range(0, len(block), 4):
            if data_out and data_out[-1] != "{":
                data_out += ",\n"
            data_out += ', '.join(["0x%02x" % b for b in block[part: part + 4]])
        data_out += "}"

    print("/* %sx%s (frames: %s, mask: %s, dim: %s) */" % (args.w, args.h, frames, args.tc is not None, args.dim))
    print("const unsigned char %s[%d][%d] = {\n%s\n};\n" % (args.id, len(out), len(out[0]), data_out))

if __name__ == "__main__":
    main()

