#!/bin/sh
DIR=$(dirname "$0")
SRC="$DIR/spinlock_irq_test.c"
OBJ="$DIR/spinlock_irq_test.o"
INC="/lib/modules/$(uname -r)/build/include"

command -v clang >/dev/null 2>&1 || {
  echo "Skipping kernel test: clang not installed" >&2
  exit 2
}

if [ ! -d "$INC" ]; then
  echo "Skipping kernel test: kernel headers missing at $INC" >&2
  exit 2
fi

set +e
clang -std=c23 -D__KERNEL__ -DMODULE -I"$INC" -c "$SRC" -o "$OBJ" 2>"$DIR/spinlock_irq_test.log"
status=$?
if [ $status -ne 0 ]; then
  cat "$DIR/spinlock_irq_test.log"
  exit 1
fi
exit 0


