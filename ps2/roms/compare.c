/* compare.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_ROW_LEN 1024

/*
 * Compare columns 10 through 37 with 49 through 76. Highlight cells that are different.
 * Then also highlight cells in columns 88 through 115. Difference between cells is 39.
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
    char buf2[MAX_ROW_LEN];
    char* ptr;
    char* ptr2;
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
            if((len > 4) && !strncmp(row, "0000", 4) && len >= 115) {
                /* 0 - 9 (10) */
                fwrite(row, sizeof(row[0]), 10, stdout);
                ptr = buf;
                ptr2 = buf2;
                diff[0] = 0;
                diff[1] = 0;
                diff[2] = 0;
                diff[3] = 0;
                diff[4] = 0;
                diff[5] = 0;
                diff[6] = 0;
                diff[7] = 0;
                diff[8] = 0;
                for(i = 10; i <= 37; i++ ) {
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
                    if(idx < 8 && row[i] != row[i + 39]) {
                        diff[idx] = 1;
                        is_diff = 1;
                    }
                    if(i >= 30 && i <= 37) {
                        idx = i - 30;
                        if(diff[idx]) is_diff = 1;
                    }  
                    if(is_diff) printf("%s", smul);
                    putchar(row[i]);
                    if(is_diff) printf("%s", rmul);
                    if(is_diff) appnd(&ptr, smul);
                    *ptr++ = row[i + 39];
                    *ptr = '\0';
                    if(is_diff) appnd(&ptr, rmul);
                    if(is_diff) appnd(&ptr2, smul);
                    *ptr2++ = row[i + 39 + 39];
                    *ptr2 = '\0';
                    if(is_diff) appnd(&ptr2, rmul);
                }
                putchar(row[i]);
                fprintf(stdout, "%s", buf);
                putchar(row[i + 39]);
                fprintf(stdout, "%s", buf2);
                puts("");
            } else {
                puts(row);
            }
        }
    }

    return 0;
}
