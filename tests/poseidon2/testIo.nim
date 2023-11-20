import std/unittest
import std/sequtils
import constantine/math/io/io_bigints
import constantine/math/arithmetic
import poseidon2/types
import poseidon2/io

suite "conversion to/from bytes":

  func toArray(bytes: openArray[byte]): array[31, byte] =
    result[0..<bytes.len] = bytes[0..<bytes.len]

  test "converts 31 little endian bytes into a field elements":
    let bytes = toArray toSeq 1'u8..31'u8
    let paddedTo32 = @bytes & @[0'u8] # most significant byte is not used
    let expected = F.fromBig(B.unmarshal(paddedTo32, littleEndian))
    let unmarshalled = F.fromBytes(bytes)
    check bool(unmarshalled == expected)

  test "converts every 31 bytes into a field element":
    let bytes = toSeq 1'u8..62'u8
    let expected1 = F.fromBytes(bytes[0..<31].toArray)
    let expected2 = F.fromBytes(bytes[31..<62].toArray)
    let elements = toSeq bytes.elements(F)
    check bool(elements[0] == expected1)
    check bool(elements[1] == expected2)

  test "conversion from bytes adds 0x1 as an end marker":
    let bytes = toSeq 1'u8..62'u8
    let marker = @[1'u8]
    let expected = F.fromBytes(marker.toArray)
    let elements = toSeq bytes.elements(F)
    check bool(elements[^1] == expected)

  test "converts empty sequence of bytes to single field element":
    let bytes = seq[byte].default
    let marker = @[1'u8]
    let expected = F.fromBytes(marker.toArray)
    let elements = toSeq bytes.elements(F)
    check elements.len == 1
    check bool(elements[0] == expected)

  test "conversion from bytes pads the last chunk when it's less than 31 bytes":
    let bytes = toSeq 1'u8..80'u8
    let marker = @[1'u8]
    let padded = bytes[62..<80] & marker & 0'u8.repeat(12)
    let expected = F.fromBytes(padded.toArray)
    let elements = toSeq bytes.elements(F)
    check bool(elements[^1] == expected)

  test "converts field element into little-endian bytes":
    var element: F
    setMinusOne(element) # largest element in the field
    var expected: array[32, byte]
    marshal(expected, element.toBig(), littleEndian)
    check element.toBytes() == expected
