all:	fonts drivers utilities1

fonts:	howard16.fnt

drivers:	glueck.sys

utilities1:	vmode2.com vmode3.com vmode7.com showfont.com clrscr.com

clean:
	rm -f ../dist/*
	rm -f howard16.fnt glueck.sys vmode2.com vmode3.com vmode7.com showfont.com clrscr.com

dist: howard16.fnt glueck.sys vmode2.com vmode3.com vmode7.com showfont.com clrscr.com
	./make_dist.sh $^

UASM_FLAGS=-0

howard16.fnt:	howard16.asm howard16.inc
	uasm $(UASM_FLAGS) -Fohoward16.fnt -bin howard16.asm

glueck.sys:	glueck.asm howard16.inc glueck.inc
	uasm $(UASM_FLAGS) -Foglueck.sys -bin glueck.asm

glueck89.sys:	glueck_1989.asm howard16.inc glueck.inc
	uasm $(UASM_FLAGS) -Foglueck89.sys -bin glueck_1989.asm

vmode2.com: vmode2.asm
	uasm $(UASM_FLAGS) -bin vmode2.asm
	mv vmode2.bin vmode2.com

vmode3.com: vmode3.asm
	uasm $(UASM_FLAGS) -bin vmode3.asm
	mv vmode3.bin vmode3.com

vmode7.com: vmode7.asm
	uasm $(UASM_FLAGS) -bin vmode7.asm
	mv vmode7.bin vmode7.com

showfont.com: showfont.asm
	uasm $(UASM_FLAGS) -bin showfont.asm
	mv showfont.bin showfont.com

clrscr.com: clrscr.asm
	uasm $(UASM_FLAGS) -bin clrscr.asm
	mv clrscr.bin clrscr.com
