import std/unittest
import std/math
import std/sequtils

import constantine/math/arithmetic
import constantine/math/io/io_fields
import constantine/math/io/io_bigints
import constantine/serialization/codecs

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
    check root.toHex(littleEndian) == "0xd1111b3515a663bb48278bfe453fe2508487014a1c6093d3ec5a6db764bbab1e"

  test "merkle root of bytes":
    let bytes = toSeq 1'u8..80'u8
    let root = merkleRoot(bytes)
    check root.toHex(littleEndian) == "0x00f5c12fabdf0fce1a69b9f0920f60e0c0ea4d8a880ae297559e0ad2276f2d2d"

  test "merkle root of bytes converted to bytes":
    let bytes = toSeq 1'u8..80'u8
    let rootAsBytes = merkleRoot(bytes).toBytes()
    check rootAsBytes.toHex == "0x00f5c12fabdf0fce1a69b9f0920f60e0c0ea4d8a880ae297559e0ad2276f2d2d"
