import std/options
import constantine/math/arithmetic
import constantine/math/io/io_bigints
import constantine/math/io/io_fields
import constantine/named/algebras
import ./types

export algebras

func fromOpenArray(_: type F, bytes: openArray[byte]): F =
  F.fromBig(B.unmarshal(bytes, littleEndian))

func fromBytes*(_: type F, bytes: array[31, byte]): F =
  ## Converts bytes into a field element. The byte array is interpreted as a
  ## canonical little-endian big integer.
  F.fromOpenArray(bytes)

func fromBytes*(_: type F, bytes: array[32, byte]): Option[F] =
  ## Converts bytes into a field element. The byte array is interpreted as a
  ## canonical little-endian big integer.
  let big = B.unmarshal(bytes, littleEndian)
  if bool(big < F.getModulus()):
    return some(F.fromBig(big))

func toBytes*(element: F): array[32, byte] =
  ## Converts a field element into its canonical representation in little-endian
  ## byte order. Uses at most 254 bits, the remaining most-significant bits are
  ## set to 0.
  assert marshal(result, element.toBig(), littleEndian)

iterator elements*(bytes: openArray[byte], _: type F): F =
  ## Converts bytes into field elements. The byte array is converted 31 bytes at
  ## a time with the `F.fromBytes()` function. An end marker (0x1) and
  ## padding (0x0's) are added to ensure unique field elements for byte
  ## sequences that end with 0x0's.
  const chunkLen = 31
  const endMarker = @[1'u8]
  var chunkStart = 0
  while chunkStart + chunkLen <= bytes.len:
    let chunkEnd = chunkStart + chunkLen - 1
    let element = F.fromOpenArray(bytes.toOpenArray(chunkStart, chunkEnd))
    yield element
    chunkStart += chunkLen
  let finalChunk = bytes[chunkStart..<bytes.len] & endMarker
  let finalElement = F.fromOpenArray(finalChunk)
  yield finalElement

# Remark: since `fromInt()` does not work at compile time, this doesn't either
func toF*(a: SomeInteger | SomeUnsignedInt) : F =
  when a is SomeInteger:
    fromInt(result, a)
  else:
    fromUInt(result, a)
