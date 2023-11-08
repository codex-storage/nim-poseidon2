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

  test "merkle root of field elements":
    let m = 17
    let n = 2^m
    var xs: seq[F]
    for i in 1..n:
      xs.add( toF(i) )

    let root = merkleRoot(xs)
    check root.toHex(littleEndian) == "0xd1111b3515a663bb48278bfe453fe2508487014a1c6093d3ec5a6db764bbab1e"

  test "merkle root of even elements":
    let elements = toSeq(1..4).mapIt(toF(it))
    let expected = compress(compress(1.toF, 2.toF), compress(3.toF, 4.toF))
    check bool(merkleRoot(elements) == expected)

  test "merkle root of odd elements":
    let elements = toSeq(1..3).mapIt(toF(it))
    let expected = compress(compress(1.toF, 2.toF), compress(3.toF, 0.toF))
    check bool(merkleRoot(elements) == expected)

  test "merkle root of bytes":
    let bytes = toSeq 1'u8..80'u8
    let root = merkleRoot(bytes)
    check root.toHex(littleEndian) == "0xa1dffa3f60d166283d60396023d95a1d7996d119e5290fe31131e7c6a7a27817"

  test "merkle root of bytes converted to bytes":
    let bytes = toSeq 1'u8..80'u8
    let rootAsBytes = merkleRoot(bytes).toBytes()
    check rootAsBytes.toHex == "0xa1dffa3f60d166283d60396023d95a1d7996d119e5290fe31131e7c6a7a27817"
