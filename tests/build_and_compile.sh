#!/bin/sh
set -e
BITS=$1
shift
DIR=$(cd "$(dirname "$0")"/.. && pwd)
cd "$DIR/bcplkit-0.9.7"
make -C src clean
BITS=$BITS sh makeall all
BCPLKITDIR=src/build/$BITS
if [ $# -eq 0 ]; then
    set -- "$DIR/tests/hello.b"
fi
for prog in "$@"; do
    BCPLKITDIR=$BCPLKITDIR sh ./src/bcpl "$prog"
done
