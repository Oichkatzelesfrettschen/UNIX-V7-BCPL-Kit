This directory provides a small helper library wrapping basic Cap'n Proto
file serialization. `helpers.h` declares two functions:

- `writeMessageToFile()` writes a packed message to disk.
- `readMessageFromFile()` reads a packed message back using a schema.

A simple `Makefile` builds `libcapnp_helpers.a` which can be linked with
user programs.
