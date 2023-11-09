# Test that the example code from the Readme.md compiles

{.hint[XDeclaredButNotUsed]: off.}

import poseidon2

let input = [1'u8, 2'u8, 3'u8] # some bytes that you want to hash
let digest: F = Sponge.digest(input) # a field element

let output: array[32, byte] = digest.toBytes

let left = Sponge.digest([1'u8, 2'u8, 3'u8])
let right = Sponge.digest([4'u8, 5'u8, 6'u8])
let combination = compress(left, right)
