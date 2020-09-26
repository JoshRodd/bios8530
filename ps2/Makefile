CC=cc
CFLAGS=-g
LIBS=
ODIR=build/
DIST_DIR=dist/
SRC_DIR=src/
BIN_DIR=bin/
DEPS=
_OBJ=splice.o
_OBJ2=romcompare.o
_TARGET=splice
_TARGET2=romcompare

OBJ=$(patsubst %,$(ODIR)/%,$(_OBJ))
OBJ2=$(patsubst %,$(ODIR)/%,$(_OBJ2))
TARGET=$(patsubst %,$(BIN_DIR)/%,$(_TARGET))
TARGET2=$(patsubst %,$(BIN_DIR)/%,$(_TARGET2))

all:	$(TARGET) $(TARGET2)

$(TARGET): $(OBJ)
	mkdir -p $(BIN_DIR)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(TARGET2): $(OBJ2)
	mkdir -p $(BIN_DIR)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(ODIR)/%.o: $(SRC_DIR)/%.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

.PHONY:	clean dist

clean:
	rm -f $(OBJ)
	rm -f $(OBJ2)
	rm -f $(TARGET)
	rm -f $(TARGET2)
	-rmdir $(ODIR)
	rm -f $(DIST_DIR)/$(_TARGET)
	rm -f $(DIST_DIR)/$(_TARGET2)
	-rmdir $(DIST_DIR)

veryclean:	clean
	rm -f $(ODIR)/*.B*
	rm -f $(DIST_DIR)/*.B*
	-rmdir $(ODIR)
	-rmdir $(DIST_DIR)

dist:	$(TARGET) $(TARGET2)
	mkdir -p $(DIST_DIR)
	strip $<
	install $< $(DIST_DIR)
