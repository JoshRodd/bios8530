all:	build/machine.json

dist:	build/machine.json
		rm -rf dist/
		mkdir -p dist/
		cp build/*.json dist/

clean:
		rm -rf build/

build/machine.json:	build/hello.com build/coldboot.com
		./make_floppy_image.sh

build/hello.com:	src/hello.asm
		mkdir -p build/
		uasm -0 -q -bin -Fl=build/hello.lst -Fobuild/hello.com src/hello.asm

build/coldboot.com:	src/coldboot.asm
		mkdir -p build/
		uasm -0 -q -bin -Fl=build/coldboot.lst -Fobuild/coldboot.com src/coldboot.asm
