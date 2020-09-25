CC=cc
CFLAGS=-g
LIBS=
ODIR=build/
DIST_DIR=dist/
DEPS=
_OBJ=splice.o
_TARGET=splice

OBJ=$(patsubst %,$(ODIR)/%,$(_OBJ))
#TARGET=$(patsubst %,$(ODIR)/%,$(_TARGET))
TARGET=$(_TARGET)

all:	$(TARGET)

$(TARGET): $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(ODIR)/%.o: %.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

.PHONY:	clean dist

clean:
	rm -f $(OBJ)
	rm -f $(TARGET)
	-rmdir $(ODIR)
	rm -f $(DIST_DIR)/$(_TARGET)
	-rmdir $(DIST_DIR)

dist:	$(TARGET)
	mkdir -p $(DIST_DIR)
	strip $<
	install $< $(DIST_DIR)
