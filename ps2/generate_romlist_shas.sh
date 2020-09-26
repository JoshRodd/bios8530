#!/bin/bash

(cd build; openssl dgst -sha256 *.BIN) > romlist_sha.txt
