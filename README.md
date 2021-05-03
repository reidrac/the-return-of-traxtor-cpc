# The Return of Traxtor (CPC)

This is the source code of [The Return of Traxtor](https://www.usebox.net/jjm/return-of-traxtor-cpc/) for the Amstrad CPC.

I'm sharing it as an historic curiosity and hoping that it may be interesting,
without any support!

It includes my first tiles/sprites engine for the CPC (see `splib.c`), although
this game is only using tiles.

Some of the dependencies are old and likely to have bugs that have been fixed
in later relases, so you shouldn't use the versions that are provided here for
any new projects. This is how the game was built in 2015!

You will need:

- A POSIX environment (Linux is perfect, Debian recommended)
- GCC, GNU Make, cmake, Python 2 and 3, PIL (or Pillow) for Python, libpng and
  libucl for development
- SDCC 3.5; later versions may not work as SDCC has changed the tool that
  manages libraries!

Once all dependencies are met, run `make`.

It should end with something like this:
```
*WARNING* Initialized data found
***
      Max: 41080 bytes
  Current: 24393 bytes (16687 bytes left)
***
```

At this point `traxtor.cdt` and `traxtor.dsk` should be ready to load in your
emulator.

## License

The source code of the game is licensed GPL 3.0, the assets are [CC-BY-SA](https://creativecommons.org/licenses/by-sa/2.0/).

The tools/libraries included that I don't own have their own copyright notices
and license (some are public domain, others are open source).

The loading screen is based on the original made by Craig Stevenson for the ZX
Spectrum.

