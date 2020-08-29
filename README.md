# HOWARD
HOWARD the FONT
Version 3.6.1

Disassembly: Josh Rodd
Original 1989 binary: Alan E. Beelitz
Font: inspired by Howard W. Glueck

This is source version of HOWARD the FONT which is a
display font manager and related utilities primarily
intended for VGA computers.

It includes code capable of loading user-defined fonts
on computers with MCGA display hardware. This source
release is primarily intended for facilitating efforts
to implement hardware emulation of MCGA equipped
computers.

It can be built using MASM or a compatible equivalent
such as uasm; the Makefile supplied has only been
tested on macOS 10.15.5 with uasm v2.47.

To build, run: ./build.sh
Or run "make dist" from the src/ directory. The
output HOWARD.ZIP file is suitable for deplying to
a PC.
