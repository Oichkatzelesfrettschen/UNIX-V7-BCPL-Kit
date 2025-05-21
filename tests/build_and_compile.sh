#!/bin/sh
set -e
BITS=$1
DIR=$(cd "$(dirname "$0")"/.. && pwd)
cd "$DIR/bcplkit-0.9.7"
make -C src clean
BITS=$BITS sh makeall all
BCPLKITDIR=src/build/$BITS ./src/bcpl "$DIR/tests/hello.b"
