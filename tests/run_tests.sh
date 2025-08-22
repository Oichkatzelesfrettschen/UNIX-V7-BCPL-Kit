#!/bin/sh
set -e
DIR=$(dirname "$0")
CC=${CC:-cc}
if printf '#include <bits/libc-header-start.h>\n' | "$CC" -m32 -E - >/dev/null 2>&1 \
 && printf '#include <stdio.h>\nint main(void){return 0;}\n' | "$CC" -m32 -x c - -o /tmp/cc32test 2>/dev/null; then
  rm -f /tmp/cc32test
  "$DIR/build_and_compile.sh" 32
else
  echo "Skipping 32-bit build: missing headers or $CC lacks usable -m32 support"
fi

if "$DIR/build_and_compile.sh" 64; then
  echo "Userland tests PASS"
else
  status=$?
  if [ $status -eq 2 ]; then
    echo "Userland tests SKIPPED"
  else
    echo "Userland tests FAIL"
    exit 1
  fi
fi

if "$DIR/build_kernel_test.sh"; then
  echo "Kernel-space tests PASS"
else
  status=$?
  if [ $status -eq 2 ]; then
    echo "Kernel-space tests SKIPPED"
  else
    echo "Kernel-space tests FAIL"
    exit 1
  fi
fi

