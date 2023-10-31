import std/unittest
import std/sequtils
import constantine/math/io/io_bigints
import constantine/math/arithmetic
import poseidon2/types
import poseidon2/io

suite "unmarshalling":

  const F123456 = F.fromBig(B.fromHex("0x123456", bigEndian))

  test "converts big endian bytes into field elements":
    let bytes = [0x12'u8, 0x34'u8, 0x56'u8]
    var padded: array[31, byte]
    padded[^3..^1] = bytes
    check bool(F.unmarshal(bytes, bigEndian)[0] == F123456)
    check bool(F.unmarshal(padded, bigEndian)[0] == F123456)

  test "converts little endian bytes into field elements":
    let bytes = [0x56'u8, 0x34'u8, 0x12'u8]
    var padded: array[31, byte]
    padded[0..<3] = bytes
    check bool(F.unmarshal(bytes, littleEndian)[0] == F123456)
    check bool(F.unmarshal(padded, littleEndian)[0] == F123456)

  test "converts every 31 bytes into a field element":
    let bytes = toSeq 1'u8..80'u8
    let element1 = F.fromBig(B.unmarshal(toSeq  1'u8..31'u8, bigEndian))
    let element2 = F.fromBig(B.unmarshal(toSeq 32'u8..62'u8, bigEndian))
    let element3 = F.fromBig(B.unmarshal(toSeq 63'u8..80'u8, bigEndian))
    let elements = F.unmarshal(bytes, bigEndian)
    check elements.len == 3
    check bool(elements[0] == element1)
    check bool(elements[1] == element2)
    check bool(elements[2] == element3)

