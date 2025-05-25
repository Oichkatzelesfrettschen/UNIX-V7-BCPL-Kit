#!/bin/sh
set -e
DIR=$(dirname "$0")
PROGS="$DIR/hello.b $DIR/mailbox_basic.b $DIR/mailbox_overflow.b $DIR/mailbox_timeout.b"
"$DIR/build_and_compile.sh" 32 $PROGS
"$DIR/build_and_compile.sh" 64 $PROGS
