# BCPL Kit 64-bit Notes

This repository originally targets 32-bit x86 systems.  The
`sys_linux64.s` file and accompanying Makefile changes provide an initial
experiment for running the compiler on 64-bit Linux.  The rest of the
runtime sources remain largely unchanged and may require additional
work to operate correctly on 64-bit systems.

To build the experimental 64-bit version:

1. Ensure `src/sys.s` links to `sys_linux64.s`.
2. Run `./makeall` or `make` within the `src` directory.

Further testing and runtime adjustments are likely required before the
compiler can fully operate in a native 64-bit environment.

## System call interface notes

Runtime assembly sources now include `sys_defs.inc`, which lists syscall
numbers for Linux (i386 and x86-64) and FreeBSD along with register usage.
These values were taken from the Linux syscall tables in the kernel source
(`arch/x86/entry/syscalls/syscall_32.tbl` and `syscall_64.tbl`) and from the
FreeBSD `sys/sys/syscall.h` header.  The 32‑bit routines continue to use the
`int $0x80` calling convention, while the 64‑bit code follows the x86‑64
`syscall` ABI with the `%rcx` argument copied to `%r10`.
