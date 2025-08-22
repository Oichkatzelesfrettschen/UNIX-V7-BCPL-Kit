#!/bin/sh
set -e
BITS=$1
DIR=$(cd "$(dirname "$0")"/.. && pwd)
cd "$DIR/bcplkit-0.9.7"
CC=${CC:-cc}
make -C src clean CC=$CC
if ! BITS=$BITS CC=$CC sh makeall all; then
  echo "Skipping BCPL build: bootstrap failed" >&2
  exit 2
fi
chmod +x src/bcpl
if [ ! -x src/build/$BITS/st ]; then
  echo "Skipping BCPL build: missing runtime 'st'" >&2
  exit 2
fi
BCPLKITDIR=src/build/$BITS ./src/bcpl "$DIR/tests/hello.b"
cd "$DIR/src-kernel"
make clean
BITS=$BITS CC=$CC make

