#!/usr/bin/env python

__version__ = "1.0"

from argparse import ArgumentParser
from PIL import Image

def main():

    parser = ArgumentParser(description="Image to cpcrslib font",
                            epilog="Copyright (C) 2015 Juan J Martinez <jjm@usebox.net>",
                            )

    parser.add_argument("--version", action="version", version="%(prog)s "  + __version__)
    parser.add_argument("image", help="image to convert")
    parser.add_argument("id", help="variable name")
    parser.add_argument("--effect", dest="effect", action="store_true")

    args = parser.parse_args()

    try:
        image = Image.open(args.image)
    except IOError:
        parser.error("failed to open the image")

    if image.mode != "P":
        parser.error("not an indexed image (no palette)")

    (w, h) = image.size
    data = image.getdata()

    out = []
    for y in range(0, h, 8):
        for x in range(0, w, 4):
            for j in range(8):
                row = 0
                for i in range(4):
                    if data[x + i + (j + y) * w] != 0:
                        if args.effect and j in (2, 3, 4, 5):
                            row |= 1 << (7 - ((i * 2) + 1))
                        row |= 1 << (7 - (i * 2))
                out.append(row)

    data_out = ""
    for part in range(0, len(out), 8):
        if data_out:
            data_out += ",\n"
        data_out += ', '.join(["0x%02x" % b for b in out[part: part + 8]])

    print("const unsigned char %s[] = {\n%s\n};\n" % (args.id, data_out))

if __name__ == "__main__":
    main()

