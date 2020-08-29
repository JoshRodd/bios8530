#!/bin/bash

cd src/ || exit
make dist || exit
mv dist/HOWARD.ZIP .
