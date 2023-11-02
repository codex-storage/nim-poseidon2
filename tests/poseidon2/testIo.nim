import std/unittest
import std/sequtils
import constantine/math/io/io_bigints
import constantine/math/arithmetic
import poseidon2/types
import poseidon2/io

suite "unmarshalling":

  test "converts little endian bytes into field elements":
    let bytes = toSeq 1'u8..31'u8
    let paddedTo32 = bytes & @[0'u8] # most significant byte is not used
    let expected = F.fromBig(B.unmarshal(paddedTo32, littleEndian))
    let unmarshalled = F.unmarshal(bytes)
    check bool(unmarshalled == expected)

  test "pads little endian bytes to the right with 0's":
    let bytes = @[0x56'u8, 0x34, 0x12]
    let paddedTo32 = bytes & 0'u8.repeat(32 - bytes.len)
    let expected = F.fromBig(B.unmarshal(paddedTo32, littleEndian))
    let unmarshalled = F.unmarshal(bytes)
    check bool(unmarshalled == expected)

  test "converts every 31 bytes into a field element":
    let bytes = toSeq 1'u8..80'u8
    let padded = bytes & 0'u8.repeat(93 - bytes.len)
    let expected1 = F.fromBig(B.unmarshal(padded[ 0..<31] & @[0'u8], littleEndian))
    let expected2 = F.fromBig(B.unmarshal(padded[31..<62] & @[0'u8], littleEndian))
    let expected3 = F.fromBig(B.unmarshal(padded[62..<93] & @[0'u8], littleEndian))
    let elements = seq[F].unmarshal(bytes)
    check elements.len == 3
    check bool(elements[0] == expected1)
    check bool(elements[1] == expected2)
    check bool(elements[2] == expected3)

