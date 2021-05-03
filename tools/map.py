#!/usr/bin/env python

__version__ = "1.0"

import sys
from argparse import ArgumentParser
import json
import subprocess
from collections import defaultdict

DEF_ROOM_WIDTH = 20
DEF_ROOM_HEIGHT = 10

def find_name(data, name):
    for item in data:
        if item.get("name").lower() == name.lower():
            return item
    raise ValueError("%r not found" % name)

def main():

    parser = ArgumentParser(description="Map importer",
                            epilog="Copyright (C) 2015 Juan J Martinez <jjm@usebox.net>",
                            )

    parser.add_argument("--version", action="version", version="%(prog)s "  + __version__)
    parser.add_argument("--room-width", dest="rw", default=DEF_ROOM_WIDTH, type=int,
                        help="room width (default: %s)" % DEF_ROOM_WIDTH)
    parser.add_argument("--room-height", dest="rh", default=DEF_ROOM_HEIGHT, type=int,
                        help="room height (default: %s)" % DEF_ROOM_HEIGHT)
    parser.add_argument("-b", dest="bin", action="store_true",
                        help="output binary data (default: C code)")
    parser.add_argument("--ucl", dest="ucl", action="store_true",
                        help="UCL compress (requires ucl binary in the path)")
    parser.add_argument("map_json", help="Map to import")
    parser.add_argument("id", help="variable name")

    args = parser.parse_args()

    with open(args.map_json, "rt") as fd:
        data = json.load(fd)

    mh = data.get("height", 0)
    mw = data.get("width", 0)

    if mh < args.rh or mh % args.rh:
        parser.error("Map size in not multiple of the room size")
    if mw < args.rw or mw % args.rw:
        parser.error("Map size in not multiple of the room size")

    tilewidth = data["tilewidth"]
    tileheight = data["tileheight"]

    tile_layer = find_name(data["layers"], "Map")["data"]

    def_tileset = find_name(data["tilesets"], "default")
    tileprops = def_tileset.get("tileproperties", {})
    firstgid = def_tileset.get("firstgid")

    out = []
    for y in range(0, mh, args.rh):
        for x in range(0, mw, args.rw):
            current = []
            for j in range(args.rh):
                for i in range(args.rw / 2):
                    a = (tile_layer[x + (i * 2) + (y + j) * mw] - firstgid) & 0b111
                    if str(a) in tileprops and tileprops[str(a)].get("blocked"):
                        a |= 0b1000

                    b = (tile_layer[x + (i * 2) + 1 + (y + j) * mw] - firstgid) & 0b111
                    if str(b) in tileprops and tileprops[str(b)].get("blocked"):
                        b |= 0b1000

                    current.append((a << 4) | b)
            out.append(current)

    if args.ucl:
        compressed = []
        for block in out:
            p = subprocess.Popen(["ucl",], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
            output, err = p.communicate(bytearray(block))
            compressed.append([ord(b) for b in output])
        out = compressed

    if args.bin:
       sys.stdout.write(bytearray(out))
       return

    print("#define WMAPS %d" % (mw // args.rw))

    if args.ucl:
        data_out = ""
        for i, block in enumerate(out):
            data_out_part = ""
            for part in range(0, len(block), args.rw // 2):
                if data_out_part:
                    data_out_part += ",\n"
                data_out_part += ', '.join(["0x%02x" % b for b in block[part: part + args.rw // 2]])
            data_out += "const unsigned char %s_%d[%d] = {\n" % (args.id, i, len(block))
            data_out += data_out_part + "\n};\n"

        data_out += "const unsigned char *%s[%d] = { " % (args.id, len(out))
        data_out += ', '.join(["%s_%d" % (args.id, i) for i in range(len(out))])
        data_out += " };\n"
        print(data_out)

    else:
        data_out = ""
        for block in out:
            if data_out:
                data_out += ",\n"
            data_out += "{"
            for part in range(0, len(block), args.rw // 2):
                if data_out and data_out[-1] != "{":
                    data_out += ",\n"
                data_out += ', '.join(["0x%02x" % b for b in block[part: part + args.rw // 2]])
            data_out += "}\n"

        print("const unsigned char %s[%d][%d] = {\n%s\n};\n" % (args.id,
            len(out), args.rh * args.rw / 2, data_out))

    enemies = 0
    entities_layer = find_name(data["layers"], "Entities")
    if len(entities_layer):
        map_ents = defaultdict(list)
        ent_tileset = find_name(data["tilesets"], "Entities")
        firstgid = ent_tileset.get("firstgid")
        for obj in entities_layer["objects"]:
            m = ((obj["x"] // tilewidth) // args.rw) \
                    + (((obj["y"] // tileheight) // args.rh) * (mw // args.rw))
            x = obj["x"] % (args.rw * tilewidth)
            y = obj["y"] % (args.rh * tileheight) - ent_tileset["tileheight"]
            t = int(ent_tileset["tileproperties"][str(obj["gid"] - firstgid)]["id"])
            # enemies start at id 10
            if t > 9:
                enemies += 1
            map_ents[m].extend([t, x, y])
            if "teleport" in obj.get("properties", {}):
                tele = json.loads(obj["properties"]["teleport"])
                tm = ((tele[0] // tilewidth) // args.rw) \
                        + (((tele[1] // tileheight) // args.rh) * (mw // args.rw))
                map_ents[m].extend([tm, tele[0] % (tilewidth * args.rw), tele[1] % (tileheight * args.rh) - ent_tileset["tileheight"]])

        for m, ents in map_ents.items():
            data_out = ", ".join(["0x%02x" % e for e in ents]) + ", 0xff"
            print("const unsigned char %s_e%d[%d] = { %s };" % (args.id, m, len(ents) + 1, data_out))

        map_map = []
        for i in range(len(out)):
            if i in map_ents:
                map_map.append("%s_e%d" % (args.id, i))
            else:
                map_map.append("(unsigned char *)0")

        print("const unsigned char *%s_ents[%d] = { %s };\n" % (args.id,
            len(out), ", ".join(map_map)))

    print("const unsigned char %s_enemies = %s;" % (args.id, enemies))

if __name__ == "__main__":
    main()

