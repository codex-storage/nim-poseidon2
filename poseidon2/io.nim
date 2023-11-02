import ./types
import constantine/math/arithmetic
import constantine/math/io/io_bigints
import constantine/math/config/curves

func fromBytes*(_: type F, bytes: openArray[byte]): F =
  ## Converts bytes into a field element. The byte array is interpreted as a
  ## canonical little-endian big integer. The array should be of length 31 bytes
  ## or less to ensure that it fits in a field of 254 bits. The remaining
  ## 6 most-significant bits are set to 0.
  assert bytes.len <= 31
  var padded: array[32, byte]
  copyMem(addr padded[0], unsafeAddr bytes[0], bytes.len)
  let bigint = B.unmarshal(padded, littleEndian)
  return F.fromBig(bigint)

func fromBytes*(_: type seq[F], bytes: openArray[byte]): seq[F] =
  ## Converts bytes into field elements. The byte array is converted 31 bytes at
  ## a time with the `F.fromBytes()` function.
  const chunkLen = 31
  var elements: seq[F]
  var chunkStart = 0
  while chunkStart < bytes.len:
    let chunkEnd = min(chunkStart + 31, bytes.len)
    let element = F.fromBytes(bytes.toOpenArray(chunkStart, chunkEnd - 1))
    elements.add(element)
    chunkStart += chunkLen
  return elements

func toBytes*(element: F): array[32, byte] =
  ## Converts a field element into its canonical representation in little-endian
  ## byte order. Uses at most 254 bits, the remaining 6 most-significant bits
  ## are set to 0.
  assert marshal(result, element.toBig(), littleEndian)
