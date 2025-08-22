These files make up the initial (2007) release of v7/x86, a port of
Seventh Edition UNIX to the x86 (i386) PC.

See https://www.nordier.com/v7x86/index.html for further details.

Repository contents
-------------------

This archive combines Robert Nordier's **BCPL compiler kit** with the
**V7/x86** UNIX sources.  The `bcplkit-0.9.7` directory holds the
compiler sources and build scripts while `releases/` and the accompanying
tar files contain the V7/x86 system.

Building the BCPL compiler
--------------------------

Enter `bcplkit-0.9.7` and run the provided script which configures the
build by linking `src/sys.s` to the appropriate system interface file:

```sh
cd bcplkit-0.9.7
sh makeall    # or ./makeall when executable
```

The script picks `sys_linux.s`, `sys_freebsd.s` or `sys_linux64.s` based
on the host platform.  You can also create the `src/sys.s` link manually.

### CMake/Ninja

After configuration, generate the build directory with CMake and the
Ninja generator:

```sh
cmake -B build -G Ninja
ninja -C build
```

Meson builds are optional and follow the same pattern:

```sh
meson setup builddir
ninja -C builddir
```

Both build systems detect Bison automatically using `find_package(BISON)`
in CMake or Meson's `bison` dependency.

Self-hosting and tests
---------------------

After a successful build you can verify the compiler by running its test
suite and then rebuilding the sources with the freshly built compiler.

```sh
./makeall test       # build and run util/cmpltest
./makeall bootstrap  # recompile the compiler and compare binaries
```

Both targets exit with a non-zero status if a failure occurs.

Kernel library
--------------

The minimal IPC support library under `src-kernel` can be built for
32- or 64-bit targets.  The Makefile enables aggressive optimisation and
extra warnings by default, which may be overridden via `CFLAGS` if
desired:

```sh
cd src-kernel
BITS=64 make      # or BITS=32 for a 32-bit build
```

The resulting archive is placed in `src-kernel/build/<bits>/libkernel.a`.

Missing components
------------------

`files/RELNOTES` notes that the source for the C compiler and the second
stage bootstrap are not distributed with V7/x86.

Further information
-------------------

See `bcplkit-0.9.7/doc/porting-to-64bit.md` for notes on experimental
64-bit support. See `doc/IPC.md` for a description of the mailbox
abstraction and its timeout semantics.

Testing
-------
Run `tests/run_tests.sh` to build the BCPL toolchain and compile a small
program in both 32- and 64-bit modes. The 32-bit step requires a compiler
that supports `-m32` and multilib headers; the script performs a sanity
check for `bits/libc-header-start.h` to verify that the 32-bit libc
development files are present. If your system lacks these components the
script skips the 32-bit build. The script also exercises a minimal kernel
module build which depends on `clang` and the currently installed Linux
kernel headers; when either is missing the module test is skipped as well.

On Debian/Ubuntu the toolchain and test prerequisites can be installed
with:

```sh
sudo apt-get install build-essential gcc-multilib libc6-dev-i386 clang \
    linux-headers-$(uname -r) pre-commit
```

Continuous integration performs the same build and test steps on GitHub
Actions.

Code quality
------------
Install `pre-commit` via your package manager or `pip install pre-commit`
and run `pre-commit install` to set up git hooks for clang-tidy. The
configuration checks C files with the C23 standard and any C++ sources
with the C++17 standard.
