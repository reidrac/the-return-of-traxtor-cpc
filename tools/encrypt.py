
def enc(key, text):
    p = 0x59
    r = []
    for c in text:
        new = ((ord(c) ^ p) ^ key) & 0xff
        r.append(new)
        p = new
    return r

def dec(key, text):
    p = 0x59
    r = []
    for c in text:
        new = ((c ^ key) ^ p) & 0xff
        r.append(new)
        p = c
    return r

res = enc(0xfe, "THE WAR IS OVER AND\nWE PREVAILED.\n\nFOR NOW...\n\nYOU ARE A LEGEND!\n\nTHANKS FOR PLAYING\nTHE GAME.\0")
print ", ".join("0x%02x" % r for r in res)

res = dec(0xfe, res)
print "".join(chr(r) for r in res)

