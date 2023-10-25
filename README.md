Nim implementation of Poseidon2
===============================

Experimental implementation of the [Poseidon 2][1] cryptographic hash function,
specialized to BN254 and t=3. Uses the [constantine][2] library for
cryptographic primitives. Neither completeness nor correctness are guaranteed at
this moment in time.

Installation
------------

Use the [Nimble][3] package manager to add `poseidon2` to an existing
project. Add the following to its .nimble file:

```nim
requires "poseidon2 >= 0.1.0 & < 0.2.0"
```

[1]: https://eprint.iacr.org/2023/323.pdf
[2]: https://github.com/mratsim/constantine
[3]: https://github.com/nim-lang/nimble
