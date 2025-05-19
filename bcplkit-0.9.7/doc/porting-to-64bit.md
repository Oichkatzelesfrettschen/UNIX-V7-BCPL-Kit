# BCPL Kit 64-bit Notes

This repository originally targets 32-bit x86 systems.  The
`sys_linux64.s` file and accompanying Makefile changes provide an initial
experiment for running the compiler on 64-bit Linux.  The rest of the
runtime sources remain largely unchanged and may require additional
work to operate correctly on 64-bit systems.

To build the experimental 64-bit version set `BITS=64` when invoking
`makeall` or `make`:

1. `BITS=64 ./makeall`
2. Or from within the `src` directory run `make BITS=64` once the link
   is in place.

The build system links `src/sys.s` to `sys_linux64.s` when `BITS=64`
and to `sys_linux.s` otherwise (the default follows the host
architecture).

Further testing and runtime adjustments are likely required before the
compiler can fully operate in a native 64-bit environment.
