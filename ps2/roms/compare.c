/* compare.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_ROW_LEN 1024

/*
 * Compare columns 10 through 37 with 50 through 77. Highlight cells that are different.
 * Then also highlight cells in columns 90 through 117. Difference between cells is 40.
 * Check rows 1 through 13.
 */

void appnd(char** ptr, char* cat) {
    while(*cat) {
        **ptr = *cat;
        (*ptr)++;
        cat++;
    }
    **ptr = '\0';
}

int main(int argc, char* argv[]) {
    char row[MAX_ROW_LEN];
    char buf[MAX_ROW_LEN];
    char* ptr;
    int rownum = -1;
    int len;
    char* smul = "\e[4m\e[1m";
    char* rmul = "\e(B\e[m";
    int i;
    int idx;
    int diff[9];
    int is_diff;

    if(!isatty(fileno(stdout)) && argc <= 1) {
        smul = "[u][b]";
        rmul = "[/b][/u]";
    }

    memset(buf, 0, MAX_ROW_LEN);

    if(argc > 1 && !strcmp(argv[1], "--debug")) {
        smul = "";
        rmul = "";
    }

    if(argc > 1 && !strcmp(argv[1], "--standout")) {
        smul = "\e[7m";
        rmul = "\e[27m";
    }

    while(!feof(stdin)) {
        fgets(row, MAX_ROW_LEN, stdin);
        if(ferror(stdin)) {
            perror("Cannot read standard input");
            return 1;
        }
        len = strlen(row);
        if(!feof(stdin)) {
            if(len < 1 || row[len - 1] != '\n') {
                fprintf(stderr, "Lines cannot be longer than %d\n", MAX_ROW_LEN);
                return 1;
            }
            row[len - 1] = '\0';
            rownum++;
            if((len > 4) && !strncmp(row, "0000", 4) && len >= 79) {
                /* 0 - 9 (10) */
                fwrite(row, sizeof(row[0]), 10, stdout);
                ptr = buf;
                diff[0] = 0;
                diff[1] = 0;
                diff[2] = 0;
                diff[3] = 0;
                diff[4] = 0;
                diff[5] = 0;
                diff[6] = 0;
                diff[7] = 0;
                diff[8] = 0;
                for(i = 10; i <= 38; i++ ) {
                    idx = -1;
                    is_diff = 0;
                    switch(i) {
                        case 10: case 11: idx = 0; break;
                        case 12: case 13: idx = 1; break;
                        case 15: case 16: idx = 2; break;
                        case 17: case 18: idx = 3; break;
                        case 20: case 21: idx = 4; break;
                        case 22: case 23: idx = 5; break;
                        case 25: case 26: idx = 6; break;
                        case 27: case 28: idx = 7; break;
                        default: idx = 8;
                    }
                    if(idx < 8 && row[i] != row[i + 40]) {
                        diff[idx] = 1;
                        is_diff = 1;
                    }
                    if(i >= 31 && i <= 38) {
                        idx = i - 31;
                        if(diff[idx]) is_diff = 1;
                    }
                    if(is_diff) printf("%s", smul);
                    putchar(row[i]);
                    if(is_diff) printf("%s", rmul);
                    if(is_diff) appnd(&ptr, smul);
                    *ptr++ = row[i + 40];
                    *ptr = '\0';
                    if(is_diff) appnd(&ptr, rmul);
                }
                for(i = 39; i <= 49; i++ ) {
                    putchar(row[i]);
                }
                fprintf(stdout, "%s", buf);
                for(i = 39 + 40; i < len; i++ ) {
                    putchar(row[i]);
                }
                puts("");
            } else {
                puts(row);
            }
        }
    }

    return 0;
}
