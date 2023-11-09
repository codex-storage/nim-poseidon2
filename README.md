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

Usage
-----

Hashing bytes into a field element with the sponge construction:
```nim
import poseidon2

let input = [1'u8, 2'u8, 3'u8] # some bytes that you want to hash
let digest: F = Sponge.digest(input) # a field element
```

Converting a field element into bytes:
```nim
let output: array[32, byte] = digest.toBytes
```

Combining field elements, useful for constructing a binary Merkle tree:
```nim
let left = Sponge.digest([1'u8, 2'u8, 3'u8])
let right = Sponge.digest([4'u8, 5'u8, 6'u8])
let combination = compress(left, right)
```

[1]: https://eprint.iacr.org/2023/323.pdf
[2]: https://github.com/mratsim/constantine
[3]: https://github.com/nim-lang/nimble
