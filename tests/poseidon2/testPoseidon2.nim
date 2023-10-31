import std/unittest
import std/math
import std/sequtils

import constantine/math/arithmetic
import constantine/math/io/io_fields
import constantine/math/io/io_bigints
import constantine/math/config/curves

import poseidon2/types
import poseidon2

suite "poseidon2":

  test "permutation in place":
    var x: F = toF(0)
    var y: F = toF(1)
    var z: F = toF(2)

    permInplace(x, y, z)

    check toDecimal(x) == "21882471761025344482456282050943515707267606647948403374880378562101343146243"
    check toDecimal(y) == "09030699330013392132529464674294378792132780497765201297316864012141442630280"
    check toDecimal(z) == "09137931384593657624554037900714196568304064431583163402259937475584578975855"

  test "merkle root of field elements":
    let m = 17
    let n = 2^m
    var xs: seq[F]
    for i in 1..n:
      xs.add( toF(i) )

    let root = merkleRoot(xs)
    check root.toHex == "0x1eabbb64b76d5aecd393601c4a01878450e23f45fe8b2748bb63a615351b11d1"

  test "merkle root of bytes":
    let bytes = toSeq 1'u8..80'u8
    let root = merkleRoot(bytes)
    check root.toHex == "0x2d2d6f27d20a9e5597e20a888a4deac0e0600f92f0b9691ace0fdfab2fc1f500"
