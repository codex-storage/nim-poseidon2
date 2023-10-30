import std/unittest
import std/math
import std/strutils
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

  test "merkle root converts every 31 bytes to a field element":
    let hex = [ # 31 bytes per field element
      "000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E",
      "1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D",
      "3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C"
    ]
    let padded = [ # padded to 32 bytes
      hex[0] & "00",
      hex[1] & "00",
      hex[2] & "00"
    ]
    let bytes = cast[seq[byte]](parseHexStr(hex.join()))
    let elements = arrayFromHex(padded, littleEndian)
    check merkleRoot(bytes).toHex == merkleRoot(elements).toHex

  test "merkle root of bytes whose length is not a not multiple of 31":
    let hex = [ # 31 bytes per field element
      "000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E",
      "1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D",
      "3E3F404142434445464748494A4B4C4D4E4F505152535455565758"
    ]
    let padded = [ # padded to 32 bytes
      hex[0] & "00",
      hex[1] & "00",
      hex[2] & "0000000000"
    ]
    let bytes = cast[seq[byte]](parseHexStr(hex.join()))
    let elements = arrayFromHex(padded, littleEndian)
    check merkleRoot(bytes).toHex == merkleRoot(elements).toHex
