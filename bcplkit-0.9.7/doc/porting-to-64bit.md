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
