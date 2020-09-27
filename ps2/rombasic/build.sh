#!/bin/bash

./to_inc.py --asm > TEST_ROM.ASM
uasm -bin -Fo=TEST_ROM.BIN TEST_ROM.ASM
openssl dgst -sha256 TEST_ROM.BIN ROMBASIC.BIN
