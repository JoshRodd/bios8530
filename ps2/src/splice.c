/* Combines an EVEN and ODD ROM into one file. */

#include <stdio.h>
#include <stdint.h>
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
unsigned char rom[MAX_ROM_SIZE];
size_t rom_size = 0;

FILE* info = NULL;

int bit_0_set[2] = {1, 1};

int combine_roms(char* filenames[], FILE* fds[], int verbose) {
    unsigned char chars[2];
    int feofs[2];
    int i;
    size_t* size = &rom_size;
    unsigned char* romptr = rom;

    *size = 0;

    do {
        for(i = EVEN_FILE; i <= ODD_FILE; i++) feofs[i] = feof(fds[i]);
        for(i = EVEN_FILE; i <= ODD_FILE; i++) {
            chars[i] = fgetc(fds[i]);
            if(!(chars[i] & 1)) bit_0_set[i] = 0;
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
        if(verbose) fprintf(stderr,"\rWritten %zu bytes...", *size);
    } while(!(feofs[EVEN_FILE] && feofs[ODD_FILE]));
    if(verbose && *size) fprintf(stderr,"\n");
    return *size;
}

int rom_info() {
    if(rom_size % 1024) fprintf(info, "ROM size: %zu bytes\n", rom_size);
    else fprintf(info, "ROM size: %dkB\n", (int)(rom_size / 1024) );
    if(rom_size >= 16) {
        unsigned char* bootptr = &(rom[rom_size - 16]);
        if(bootptr[0] == 0xEA) { /* JMP FAR instruction */
            uint16_t off = bootptr[1]+(bootptr[2]<<8);
            uint16_t seg = bootptr[3]+(bootptr[4]<<8);
            unsigned char date[9];
            fprintf(info, "Entry point: %X:%X\n", seg, off);
            memcpy(date, &(bootptr[5]), 8);
            date[8] = '\0';
            if(date[2] == '/' && date[5] == '/')
                fprintf(info, "Date: %s\n", date);
            else
                fprintf(info, "Does not have a valid date.\n");
            switch(bootptr[14]) {
                case 0xFA: switch(bootptr[15]) {
                    case 0xC3: fprintf(info, "IBM PS/2 Model 25\n"); break;
                    default: fprintf(info, "IBM PS/2 Model 25 or 30 - unknown submodel\n");
                } break;
                default: fprintf(info, "Unknown model type %hhXh\n", bootptr[14]);
            }
            if(bootptr[13] != 0xFF) {
                fprintf(info,"Unexpected model type preamble %hhXh\n", bootptr[13]);
            }
        }
    } else {
        fprintf(info, "ROM is less than 16 bytes; unable to deduce more information.\n");
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
                if(bit_0_set[EVEN_FILE])
                    fprintf(stderr, "%s: Warning: Even file %s always has bit 0 set.\n",
                        argv0, filenames[EVEN_FILE]);
                if(bit_0_set[ODD_FILE])
                    fprintf(stderr, "%s: Warning: Odd file %s always has bit 0 set.\n",
                        argv0, filenames[ODD_FILE]);
            }
            if(verbose) return rom_info();
            else return 0;
        default:
            fprintf(stderr,"Internal error\n");
            return 1;
    }

    return 0;
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
