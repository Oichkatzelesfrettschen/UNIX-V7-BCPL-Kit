#!/bin/sh
set -e
DIR=$(dirname "$0")
"$DIR/build_and_compile.sh" 32
"$DIR/build_and_compile.sh" 64
