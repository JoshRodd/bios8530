IBM PS/2 Model 25/30 BIOS information centre
============================================

Last updated 28 Sept. 2020

Getting started
---------------

This code has, so far, only been tested on macOS, but it should
work easily on other Linux or Unix types of systems, or inside
Cygwin.

Currently the assembler used is uasm, which you will need to
install with `brew install uasm`. In theory, other assemblers
could be used.

Run `make` to build the `splice` program and several other
utilities.

Run `./get_roms.sh` to download the necessary ROMs. The sources
for these ROMs is in `doc/manifest.txt`.

Run `./build_roms.sh` to build the ROMs, which will be placed
into `dist/`. If successful, you should see output like this:

```
   Filenames      ROM    Model                Font vectors           ROM BASIC   Copy-    Part numbers  
  Even    Odd     Date               8x16    8x8 (VGA/MCGA)   8x8      vector   rights    Even     Odd  
68X1687 68X1627: 09/02/86 8530 8x16: 3960h 8x8V: 4960h 8x8: FA6Eh BASIC: 6000h 1981 1987 68X1645 68X1693  Part number mismatch
61X8938 61X8937: 12/12/86 8530 8x16: 3A30h 8x8V: 4A30h 8x8: FA6Eh BASIC: 6000h 1981 1987 61X8938 61X8937 
61X8940 61X8939: 02/05/87 8530 8x16: 3A30h 8x8V: 4A30h 8x8: FA6Eh BASIC: 6000h 1981 1987 61X8940 61X8939 
00F2122 00F2123: 06/26/87 8525 8x16: 2F48h 8x8V: 3F48h 8x8: FA6Eh BASIC: 6000h 1981 1987 00F2122 00F2123 
33F4498 33F4499: 01/31/89 8530 8x16: 3A70h 8x8V: 4A70h 8x8: FA6Eh BASIC: 6000h 1981 1989 33F4498 33F4499 
```

Extractors
----------

The `extractors/` directory contains utilities to extract
ROM BASIC and fonts from the ROMs generated by `build_roms.sh`.
You can run `check_roms.sh` and if successful, it will generate
the following programs which can be assembled to generate an
identical binary as extracted from the ROMs.

```
ROMBASIC.ASM    32kB of IBM BASIC C1.10
FONT8X8.ASM     Low 128 characters of IBM 8x8 font
FONT8X8V.ASM    256 characters of IBM 8x8 font
FONT8X16.ASM    256 characters of IBM 8x16 font
OLDF8X16.ASM    IBM 8x16 font with older design of 0, etc.
```

Documentation
-------------

Documentation is in `doc/`, including a memory map.

Disassembly
-----------

An attempt at disassembly is in `bios/`. The first attempt at
this is oriented towards the oldest BIOS (68X1645).