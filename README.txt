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
build by linking `src/sys.s` to the appropriate system interface file and
then invokes `make`:

```sh
cd bcplkit-0.9.7
sh makeall    # or ./makeall when executable
```

The script picks `sys_linux.s`, `sys_freebsd.s` or `sys_linux64.s` based
on the host platform.  You can also create the `src/sys.s` link manually
and run `make` inside the `src` directory.

Missing components
------------------

`files/RELNOTES` notes that the source for the C compiler and the second
stage bootstrap are not distributed with V7/x86.

Further information
-------------------

See `bcplkit-0.9.7/doc/porting-to-64bit.md` for notes on experimental
64-bit support.
