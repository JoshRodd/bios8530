/* showfont.c */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

int main(int argc, char* argv[]) {
    int height = 8;
    unsigned int index = 0x0f1a8;
    FILE* fd = stdin;
    int i;
    int c;

    if(argc > 1) {
        argv++; argc--;
        sscanf(*argv, "%x", &index);
    }
    if(argc > 1) {
        argv++; argc--;
        height = atoi(*argv);
        if(height < 1) {
            fprintf(stderr, "Height parameter %s is not valid; valid range is 1 or higher\n", *argv);
            return 1;
        }
    }
    if(argc > 1) {
        argv++; argc--;
        if(strcmp(*argv, "-")) {
            if(!(fd = fopen(*argv, "rb"))) {
                fprintf(stderr, "Cannot open input file %s: %s\n", *argv, strerror(errno));
                return 1;
            }
        }
    }
    if(fseek(fd, index, SEEK_CUR) < 0) {
        fprintf(stderr, "Cannot seek input file: %s\n", strerror(errno));
        return 1;
    }
    for(i = 0; i < height; i++ ) {
        c = fgetc(fd);
        fprintf(stdout, "0000%4x %2x ", index + i, c);
        if(feof(fd)) {
            fprintf(stderr, "Prematurely reached end of file\n");
            return 1;
        }
        if(ferror(fd)) {
            fprintf(stderr, "Cannot read input file: %s\n", strerror(errno));
            return 1;
        }
        putchar(c & 0x80 ? '#' : ' ');
        putchar(c & 0x40 ? '#' : ' ');
        putchar(c & 0x20 ? '#' : ' ');
        putchar(c & 0x10 ? '#' : ' ');
        putchar(c & 0x08 ? '#' : ' ');
        putchar(c & 0x04 ? '#' : ' ');
        putchar(c & 0x02 ? '#' : ' ');
        putchar(c & 0x01 ? '#' : ' ');
        puts("");
    }   
    return 0;
}
