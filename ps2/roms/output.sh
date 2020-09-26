#!/bin/bash

cc compare.c; ./a.out < comparison.txt | sed s';\[/b\]\[/u\]\[u\]\[b\];;'g | pbcopy
