# BCPL Kit 64-bit Notes

This repository originally targets 32-bit x86 systems.  The
`sys_linux64.s` file together with updates to `makeall` and the main
`src/Makefile` allow the sources to be compiled for either 32‑bit or
64‑bit hosts.  Most runtime sources are still the original 32‑bit
variants and therefore additional work may be required for a
fully‑functional 64‑bit environment.


### Building for 32‑ or 64‑bit

Running `makeall` selects an interface file based on the host and then
invokes `make` in each subdirectory.  The build script honours a
`BITS` variable which controls the word size of the resulting binaries
and is passed through to each Makefile.  For example,

To build the experimental 64-bit version set `BITS=64` when invoking
`makeall` or `make`:

1. `BITS=64 ./makeall`
2. Or from within the `src` directory run `make BITS=64` once the link
   is in place.

The build system links `src/sys.s` to `sys_linux64.s` when `BITS=64`
and to `sys_linux.s` otherwise (the default follows the host
architecture).


```sh
./makeall            # build for the host (32‑bit default on x86‑64)
BITS=64 ./makeall    # force a 64‑bit build
BITS=32 ./makeall    # force a 32‑bit build
```

`make` may also be run directly in `src` with `BITS` set.  Object files
are placed under `build/32` or `build/64` depending on the value of this
variable.

The helper file `src/sys.s` is a link to the appropriate system
interface (`sys_linux.s`, `sys_linux64.s`, or `sys_freebsd.s`).

### Register macros

The startup and system interface code use small macros for the core
registers so the same sources assemble for both 32‑bit and 64‑bit x86.
The file `src/regs.inc` defines aliases such as:

```
RA RB RC RD RSI RDI RBP RSP
```

These expand to `%eax`..`%esp` for 32‑bit and `%rax`..`%rsp` for 64‑bit
builds.  They appear throughout `su.s` and the `sys_*` files to avoid
hard coded register names.

System call numbers are collected in `syscall_defs.inc`.  The values
mirror those listed in the Linux `syscall_*.tbl` files and the FreeBSD
`syscall.h` header.  Each `sys_*.s` file includes this header so the
same symbolic names can be used for both 32‑bit and 64‑bit builds.

### Remaining 32‑bit assumptions

The compiler and interpreter still define `WORDSIZE` as 32 and operate on
4‑byte words.  Pointer arithmetic and stack frame layouts likewise use
32‑bit quantities.  While the startup code can run in 64‑bit mode, the
BCPL runtime and generated code continue to assume 32‑bit addresses.
Further testing and refactoring are required before the compiler can
fully operate in a native 64‑bit environment.
In particular the heap manager, interpreter and generated code still
address memory using 32‑bit offsets so large address spaces are not yet
accessible.
