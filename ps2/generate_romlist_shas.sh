#!/bin/bash

(cd build; openssl dgst -sha256 *.BIN *.BAD) > romlist_sha.txt
