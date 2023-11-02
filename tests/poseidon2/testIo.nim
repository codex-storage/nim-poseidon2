import std/unittest
import std/sequtils
import constantine/math/io/io_bigints
import constantine/math/arithmetic
import poseidon2/types
import poseidon2/io

suite "unmarshalling":

  test "converts big endian bytes into field elements":
    let bytes = toSeq 1'u8..31'u8
    let paddedTo32 = @[0x00'u8] & bytes # most significant byte is not used
    let expected = F.fromBig(B.unmarshal(paddedTo32, bigEndian))
    let unmarshalled = F.unmarshal(bytes, bigEndian)
    check bool(unmarshalled == expected)

  test "converts little endian bytes into field elements":
    let bytes = toSeq 1'u8..31'u8
    let paddedTo32 = bytes & @[0x00'u8] # most significant byte is not used
    let expected = F.fromBig(B.unmarshal(paddedTo32, littleEndian))
    let unmarshalled = F.unmarshal(bytes, littleEndian)
    check bool(unmarshalled == expected)

  test "pads big endian bytes to the right with 0's":
    let bytes = @[0x12'u8, 0x34, 0x56]
    let paddedTo31 = bytes & 0x00'u8.repeat(31 - bytes.len)
    let paddedTo32 = @[0x00'u8] & paddedTo31 # most significant byte is not used
    let expected = F.fromBig(B.unmarshal(paddedTo32, bigEndian))
    let unmarshalled = F.unmarshal(bytes, bigEndian)
    check bool(unmarshalled == expected)

  test "pads little endian bytes to the right with 0's":
    let bytes = @[0x56'u8, 0x34, 0x12]
    let paddedTo31 = bytes & 0x00'u8.repeat(31 - bytes.len)
    let paddedTo32 = paddedTo31 & @[0x00'u8] # most significant byte is not used
    let expected = F.fromBig(B.unmarshal(paddedTo32, littleEndian))
    let unmarshalled = F.unmarshal(bytes, littleEndian)
    check bool(unmarshalled == expected)

  test "converts every 31 bytes into a field element":
    template checkConversion(endian) =
      let bytes = toSeq 1'u8..80'u8
      let padded = bytes & 0'u8.repeat(93 - bytes.len)
      let expected1 = F.fromBig(B.unmarshal(padded[ 0..<31], endian))
      let expected2 = F.fromBig(B.unmarshal(padded[31..<62], endian))
      let expected3 = F.fromBig(B.unmarshal(padded[62..<93], endian))
      let elements = seq[F].unmarshal(bytes, endian)
      check elements.len == 3
      check bool(elements[0] == expected1)
      check bool(elements[1] == expected2)
      check bool(elements[2] == expected3)

    checkConversion(littleEndian)
    checkConversion(bigEndian)

