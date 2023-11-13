import std/unittest
import std/math
import std/sequtils

import constantine/math/arithmetic
import constantine/math/io/io_fields
import constantine/math/io/io_bigints
import constantine/serialization/codecs

import poseidon2/types
import poseidon2/io
import poseidon2/compress
import poseidon2/merkle

suite "merkle root":

  const isBottomLayer = 1
  const isOddNode = 2

  test "merkle root of field elements":
    let m = 17
    let n = 2^m
    var xs: seq[F]
    for i in 1..n:
      xs.add( toF(i) )

    let root = merkleRoot(xs)
    check root.toHex(littleEndian) == "0x593e01f200cb1aee4e75fe2a9206abc3abd2a1216ab75f1061965e97371e8623"

  test "merkle root of even elements":
    let elements = toSeq(1..4).mapIt(toF(it))
    let expected = compress(
      compress(1.toF, 2.toF, key = isBottomLayer.toF),
      compress(3.toF, 4.toF, key = isBottomLayer.toF),
    )
    check bool(merkleRoot(elements) == expected)

  test "merkle root of odd elements":
    let elements = toSeq(1..3).mapIt(toF(it))
    let expected = compress(
      compress(1.toF, 2.toF, key = isBottomLayer.toF),
      compress(3.toF, 0.toF, key = (isBottomLayer + isOddNode).toF)
    )
    check bool(merkleRoot(elements) == expected)

  test "data ending with 0 differs from padded data":
    let a = toSeq(1..3).mapIt(it.toF)
    let b = a & @[0.toF]
    check not bool(merkleRoot(a) == merkleRoot(b))

  test "merkle root of bytes":
    let bytes = toSeq 1'u8..80'u8
    let root = merkleRoot(bytes)
    check root.toHex(littleEndian) == "0x40989b63104f39e3331767883381085bcfc46e2202679123371f1ffe53521b16"

  test "merkle root of bytes converted to bytes":
    let bytes = toSeq 1'u8..80'u8
    let rootAsBytes = merkleRoot(bytes).toBytes()
    check rootAsBytes.toHex == "0x40989b63104f39e3331767883381085bcfc46e2202679123371f1ffe53521b16"
