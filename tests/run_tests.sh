#!/bin/sh
set -e
DIR=$(dirname "$0")
"$DIR/build_and_compile.sh" 32
"$DIR/build_and_compile.sh" 64

if "$DIR/build_kernel_test.sh"; then
    echo "Kernel-space tests PASS"
else
    echo "Kernel-space tests FAIL"
    exit 1
fi
