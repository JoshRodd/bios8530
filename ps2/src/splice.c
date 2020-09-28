/* Combines an EVEN and ODD ROM into one file. */

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <errno.h>

#define PROGRAM_NAME "splice"
#define VERSION_TEXT PROGRAM_NAME " v1.0"

#define USAGE_TEXT_1 "Usage: "
#define USAGE_TEXT_2 " [OPTIONS]\n\
       ROM.BIN | EVEN_ROM.BIN ODD_ROM.BIN [OUTPUT_ROM.BIN]"

int help_message(char* argv0) {
    printf("\n%s\n\
\n\
Combines an EVEN and ODD ROM into one file.\n\
\n\
%s%s%s\n\
\n\
EVEN_ROM.BIN or ODD_ROM.BIN may be replaced with a - option.  If so, standard\n\
input will be used. OUTPUT_ROM.BIN may be replaced with a - option. If so,\n\
standard output will be used.  If no output file is given, the input files will\n\
be checked, and if --verbose is given, have information printed about them, but\n\
no output file will be written.  If only one input file is given, the input\n\
file will be checked as if it is the output ROM.\n\
\n\
Optional arguments are:\n\
\n\
--verbose: Print information about the input ROM files.\n\
--help: Print this help message.\n\
--version: Print the current version.\n\
\n", VERSION_TEXT, USAGE_TEXT_1, argv0, USAGE_TEXT_2);
    return 0;
}

int version_message() {
    puts(VERSION_TEXT);
    return 0;
}

int usage_message(char* argv0) {
    printf("%s%s%s\n", USAGE_TEXT_1, argv0, USAGE_TEXT_2);
    return 1;
}

#define EVEN_FILE 0
#define ODD_FILE 1
#define OUTPUT_FILE 2
#define NUM_FILENAMES 3

#define MAX_ROM_SIZE 1048576
uint8_t rom[MAX_ROM_SIZE];
size_t rom_size = 0;
FILE* info = NULL;
int bits_set[2];
int clear_bit_0_in_even = 0;

#define SIG8X16_OFFSET (219 * 16)
uint8_t sig8x16[] = {
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255     /*; CHR$(219)*/
   ,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255                   /*; CHR$(220)*/
   ,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240     /*; CHR$(221)*/
   ,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15                     /*; CHR$(222)*/
};

#define SIG8X8V_OFFSET (219 * 8)
uint8_t sig8x8v[] = {
    255,255,255,255,255,255,255,255     /*; CHR$(219)*/
   ,0,0,0,0,255,255,255,255             /*; CHR$(220)*/
   ,240,240,240,240,240,240,240,240     /*; CHR$(221)*/
   ,15,15,15,15,15,15,15,15             /*; CHR$(222)*/
};

#define SIG8X8_OFFSET (17 * 8)
uint8_t sig8x8[] = {
    2,14,62,254,62,14,2,0               /*; CHR$(17)*/
   ,24,60,126,24,24,126,60,24           /*; CHR$(18)*/
   ,102,102,102,102,102,0,102,0         /*; CHR$(19)*/
   ,127,219,219,123,27,27,27,0          /*; CHR$(20)*/
};

#define SIGROMBASIC_OFFSET 0x7FDD
unsigned char sigrombasic[] = "Bytes free";

int combine_roms(char* filenames[], FILE* fds[], int verbose) {
    unsigned char chars[2];
    int feofs[2];
    int i;
    size_t* size = &rom_size;
    unsigned char* romptr = rom;

    *size = 0;
    bits_set[EVEN_FILE] = 0xFF;
    bits_set[ODD_FILE] = 0XFF;

    do {
        for(i = EVEN_FILE; i <= ODD_FILE; i++) feofs[i] = feof(fds[i]);
        for(i = EVEN_FILE; i <= ODD_FILE; i++) {
            chars[i] = fgetc(fds[i]);
            if(*size <= 0x2180) {
                if(!(chars[i] & 1)) bits_set[i] &= ~1;
                if(!(chars[i] & 2)) bits_set[i] &= ~2;
                if(!(chars[i] & 4)) bits_set[i] &= ~4;
                if(!(chars[i] & 8)) bits_set[i] &= ~8;
                if(!(chars[i] & 16)) bits_set[i] &= ~16;
                if(!(chars[i] & 32)) bits_set[i] &= ~32;
                if(!(chars[i] & 64)) bits_set[i] &= ~64;
                if(!(chars[i] & 128)) bits_set[i] &= ~128;
            }
            if(clear_bit_0_in_even && i == EVEN_FILE) chars[i] &= 0xFE;
            if(ferror(fds[i])) {
                fprintf(stderr, "Error reading file %s: %s\n", filenames[i], strerror(errno));
                return *size;
            }
            feofs[i] = feof(fds[i]);
            if((i == EVEN_FILE && !feofs[i]) ||
               (i == ODD_FILE && !feofs[EVEN_FILE] && !feofs[i])) {
                fputc(chars[i], fds[OUTPUT_FILE]);
                if(ferror(fds[i])) {
                    fprintf(stderr, "Error writing file %s: %s\n", filenames[OUTPUT_FILE], strerror(errno));
                    return *size;
                }
                *romptr++ = chars[i];
                (*size)++;
            }
        }
        if((feofs[EVEN_FILE] && feofs[ODD_FILE])) break;
        if(feofs[EVEN_FILE] && !feofs[ODD_FILE]) {
            fprintf(stderr, "Warning: Even file is shorter than odd file.\n");
            return *size;
        }
        if(!feofs[EVEN_FILE] && feofs[ODD_FILE]) {
            fprintf(stderr, "Warning: Odd file is shorter than even file.\n");
            return *size;
        }
/*        if(verbose) fprintf(stderr,"\rWritten %zu bytes...", *size);*/
    } while(!(feofs[EVEN_FILE] && feofs[ODD_FILE]));
/*    if(verbose && *size) fprintf(stderr,"\n");*/
    return *size;
}

int rom_info() {
    unsigned char c; unsigned char* ptr; int i;
    if(rom_size == 65536) ;
    else if(rom_size % 1024) fprintf(info, "Size: %zu bytes ", rom_size);
    else fprintf(info, "Size: %dkB ", (int)(rom_size / 1024) );
    if(rom_size >= 16) {
        unsigned char* bootptr = &(rom[rom_size - 16]);
        if(bootptr[0] == 0xEA) { /* JMP FAR instruction */
            uint16_t off = bootptr[1]+(bootptr[2]<<8);
            uint16_t seg = bootptr[3]+(bootptr[4]<<8);
            unsigned char date[9];
            if(seg != 0xF000 || off != 0xE05B)
                fprintf(info, "Start: %X:%X ", seg, off);
            memcpy(date, &(bootptr[5]), 8);
            date[8] = '\0';
            if(date[2] == '/' && date[5] == '/')
                fprintf(info, "%s ", date);
            else
                fprintf(info, "No date. ");
            switch(bootptr[14] | bootptr[13] << 8) {
                case 0x00FA: fprintf(info, "8530 "); break;
                case 0xFFFA: fprintf(info, "8525 "); break;
                default: fprintf(info, "Unknown model type %hhXh (submodel %hhXh)", bootptr[14], bootptr[13]);
            }
            {
                uint8_t* ptrfind = NULL;
                ptrdiff_t offset;
                ptrdiff_t romplussize;
                uint8_t* romplus;

                ptrfind = memmem(rom, rom_size, sig8x16, sizeof(sig8x16));
                if(ptrfind != NULL) {
                    offset = ptrfind - rom - SIG8X16_OFFSET;
                    fprintf(info, "8x16: %tXh ", offset); }

                ptrfind = memmem(rom, rom_size, sig8x8v, sizeof(sig8x8v));
                if(ptrfind != NULL) {
                    offset = ptrfind - rom - SIG8X8V_OFFSET;
                    fprintf(info, "8x8V: %tXh ", offset); }

                romplussize = offset + 8 * 256;
                ptrfind = memmem(rom + romplussize, rom_size - romplussize, sig8x8, sizeof(sig8x8));
                if(ptrfind != NULL) {
                    offset = ptrfind - rom - SIG8X8_OFFSET;
                    fprintf(info, "8x8: %tXh ", offset); }

                ptrfind = memmem(rom, rom_size, sigrombasic, sizeof(sigrombasic));
                if(ptrfind != NULL) {
                    offset = ptrfind - rom - SIGROMBASIC_OFFSET;
                    fprintf(info, "BASIC: %tXh ", offset); }
            }
        }
        /* Check for odd and even switched around */
        else if((bootptr[1] & ~bits_set[1]) == 0xEA) {
            /* Normal:
             *
             * ea5b e000 f030 322f 3035 2f38 3700 fada  .[...02/05/87...
             *
             * Transposed:
             *
             * 5bea 00e0 30f0 2f32 3530 382f 0037 dafa  [...0./2508/.7..
             */

           if(bootptr[6] == '/' && bootptr[11] == '/') {
               fprintf(info,"Warning: the odd and even sections appear to be transposed.\n");
           }
        }
        /* Check for an even ROM by itself:
         *
         * 09b9 0f75 b1ef 4be1 ebe1 f133 312f 37fb  ...u..K....31/7.
         * (this also has all bits 0 set) */
        else if(((bootptr[8]) & ~1) == 0xEA && bootptr[13] == '/') {
            fprintf(info,"Warning: this appears to be the even half of a ROM.\n");
        }
        /* Odd ROM:
         * eea0 48fd 0c4a eb00 5b00 312f 3238 00b7  ..H..J..[.1/28..
         */
        else if(((bootptr[11] == '/') && (bootptr[6] != '/'))) {
            fprintf(info,"Warning: this appears to be the odd half of a ROM.\n");
        }
    } else {
        fprintf(info, "ROM is less than 16 bytes; unable to deduce more information.\n");
    }
    c = 0; ptr = rom;
    for(i = 0; i < rom_size; i++ )
        c += *ptr++;
    if(c) {
        fprintf(info, "Warning: Invalid checksum %hhXh (-%hhXh)\n", ptr[-1], c);
    }
    return 0;
}

int rom_info_file(char* filename, FILE* fd, int verbose) {
    rom_size = fread(rom, sizeof(*rom), MAX_ROM_SIZE, fd);
    if(!feof(fd)) {
        fprintf(stderr, "Warning: ROM size exceeds maximum supported size of %zu\n", (size_t)MAX_ROM_SIZE);
    }
    if(ferror(fd)) {
        fprintf(stderr, "Error reading file %s: %s\n", filename, strerror(errno));
    }
    return rom_info();
}

int main_proc(int argc, char* argv[], char* filenames[], FILE* fds[]) {
    int ifilename = 0;
    char* arg;
    char* argv0;
    int in_options = 1;
    int stdin_available = 1;
    int verbose = 0;
    int rc;
    size_t size;

    if(argc > 0) {
        argv0 = argv[0]; argc--;
    } else {
        argv0 = "splice";
    }
    while(argc > 0 && *argv) {
        argv++; argc--; /* Always skip argument 0 */
        arg = *argv;
        if(*arg == '-' && arg[1] == '-' && in_options) {
            arg += 2;
            if(!strcmp(arg,"help")) return help_message(argv0);
            else if(!strcmp(arg,"version")) return version_message();
            else if(!strcmp(arg,"verbose")) verbose = 1;
            else if(!strcmp(arg,"no-verbose")) verbose = 0;
            else if(!strcmp(arg,"clear-even-bit-0")) clear_bit_0_in_even = 1;
            else if(!strcmp(arg,"no-clear-even-bit-0")) clear_bit_0_in_even = 1;
            else if(!*arg) in_options = 0;
            else {
                fprintf(stderr, "%s: Unknown option '--%s'.\n", argv0, arg);
                return 1;
            }
        } else if(*arg == '-' && arg[1] != '-' && arg[1] ) {
            arg += 1;
            fprintf(stderr, "%s: Unknown option '-%s'.\n", argv0, arg);
            return 1;
        } else {
            if(ifilename < NUM_FILENAMES) {
                filenames[ifilename] = arg;
                if(!strcmp(arg, "-")) {
                    if(ifilename < OUTPUT_FILE && stdin_available) {
                        fds[ifilename] = stdin;
                        filenames[ifilename] = "(standard input)";
                        stdin_available = 0;
                    }
                    else if (ifilename >= OUTPUT_FILE) {
                        fds[ifilename] = stdout;
                        info = stderr;
                        filenames[ifilename] = "(standard output)";
                    }
                    else {
                        fprintf(stderr, "%s: Cannot use more than one - entry for standard input.\n", argv0);
                        return 1;
                    }
                } else {
                    char* mode;
                    if(ifilename < OUTPUT_FILE) mode = "rb"; else mode = "wb";
                    if(!(fds[ifilename] = fopen(arg, mode))) {
                        fprintf(stderr, "%s: Cannot open file %s: %s\n", argv0, arg, strerror(errno));
                        return 1;
                    }
                }
                ifilename++;
            } else {
                fprintf(stderr, "%s: Too many filenames given; maximum of %d.\n", argv0, NUM_FILENAMES);
                return 1;
            }
        }
    }

    switch(ifilename) {
        case 0: return usage_message(argv0);
        case 1: return rom_info_file(filenames[0], fds[0], verbose);
        case 2: 
            fds[ifilename] = stdout;
            info = stderr;
            filenames[ifilename] = "(standard output)";
            ifilename++;
        case 3:
            size = combine_roms(filenames, fds, verbose);
            if(!size) {
                fprintf(stderr, "%s: Warning: Output file is empty\n", argv0);
            } else {
                if(bits_set[EVEN_FILE])
                    fprintf(stderr, "%s: Warning: Even file %s always has bits 0%Xh set.\n",
                        argv0, filenames[EVEN_FILE], bits_set[EVEN_FILE]);
                if(bits_set[ODD_FILE])
                    fprintf(stderr, "%s: Warning: Odd file %s always has bits 0%Xh set.\n",
                        argv0, filenames[ODD_FILE], bits_set[ODD_FILE]);
            }
            if(clear_bit_0_in_even) {
                fprintf(stderr, "Warning: the --clear-bit-0-in-even option was specified.\n\
The output file will have bit 0 cleared in every even byte.\n");
            }
            if(verbose) return rom_info();
            else return 0;
        default:
            fprintf(stderr,"Internal error\n");
            return 1;
    }

    fprintf(stderr,"Internal error\n");
    return 1;
}

int main(int argc, char* argv[]) {
    char* filenames[NUM_FILENAMES];
    FILE* fds[NUM_FILENAMES];
    int rc;
    int ifilename;
    
    info = stdout;

    for(ifilename = 0; ifilename < NUM_FILENAMES; ifilename++) {
        filenames[ifilename] = NULL;
        fds[ifilename] = NULL;
    }
    rc = main_proc(argc, argv, filenames, fds);
    for(ifilename = 0; ifilename < NUM_FILENAMES; ifilename++)
        if(fds[ifilename])
            fclose(fds[ifilename]);

    return rc;
}
