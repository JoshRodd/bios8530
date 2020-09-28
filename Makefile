CC=cc
CFLAGS=-g
LIBS=
BUILD_DIR=build/
DIST_DIR=dist/
SRC_DIR=src/
BIN_DIR=bin/
DEPS=
_OBJ=splice.o
_OBJ2=romcompare.o
_OBJ3=showfont.o
_TARGET=splice
_TARGET2=romcompare
_TARGET3=showfont

OBJ=$(patsubst %,$(BUILD_DIR)/%,$(_OBJ))
OBJ2=$(patsubst %,$(BUILD_DIR)/%,$(_OBJ2))
OBJ3=$(patsubst %,$(BUILD_DIR)/%,$(_OBJ3))
TARGET=$(patsubst %,$(BIN_DIR)/%,$(_TARGET))
TARGET2=$(patsubst %,$(BIN_DIR)/%,$(_TARGET2))
TARGET3=$(patsubst %,$(BIN_DIR)/%,$(_TARGET3))

all:	$(TARGET) $(TARGET2) $(TARGET3)

$(TARGET): $(OBJ)
	mkdir -p $(BIN_DIR)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(TARGET2): $(OBJ2)
	mkdir -p $(BIN_DIR)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(TARGET3): $(OBJ3)
	mkdir -p $(BIN_DIR)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(DEPS)
	mkdir -p $(BUILD_DIR)
	$(CC) -c -o $@ $< $(CFLAGS)

.PHONY:	clean dist

clean:
	rm -f $(OBJ)
	rm -f $(OBJ2)
	rm -f $(OBJ3)
	rm -f $(TARGET)
	rm -f $(TARGET2)
	rm -f $(TARGET3)
	-rmdir $(BUILD_DIR)
	rm -f $(DIST_DIR)/$(_TARGET)
	rm -f $(DIST_DIR)/$(_TARGET2)
	rm -f $(DIST_DIR)/$(_TARGET3)
	-rmdir $(DIST_DIR)

veryclean:	clean
	rm -f $(BUILD_DIR)/*.B*
	rm -f $(DIST_DIR)/*.B*
	-rmdir $(BUILD_DIR)
	-rmdir $(DIST_DIR)

dist:	$(TARGET) $(TARGET2) $(TARGET3)
	mkdir -p $(DIST_DIR)
	strip $<
	install $< $(DIST_DIR)
