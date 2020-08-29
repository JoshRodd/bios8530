#!/bin/bash

cd src/ || exit

make dist
mv dist/howard.zip .
