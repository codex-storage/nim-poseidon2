import ./types
import constantine/math/arithmetic
import constantine/math/io/io_bigints

func padRight(source: openArray[byte], endian: static Endianness): array[32, byte] =
  assert source.len <= 31
  when endian == littleEndian:
    copyMem(addr result[0], unsafeAddr source[0], source.len)
  when endian == bigEndian:
    copyMem(addr result[1], unsafeAddr source[0], source.len)

func unmarshal*(
        _: type F,
        bytes: openArray[byte],
        endian: static Endianness): F =
  assert bytes.len <= 31
  let padded = bytes.padRight(endian)
  let bigint = B.unmarshal(padded, endian)
  return F.fromBig(bigint)

func unmarshal*(
        _: type seq[F],
        bytes: openArray[byte],
        endian: static Endianness): seq[F] =
  const chunkLen = 31
  var elements: seq[F]
  var chunkStart = 0
  while chunkStart < bytes.len:
    let chunkEnd = min(chunkStart + 31, bytes.len)
    let element = F.unmarshal(bytes.toOpenArray(chunkStart, chunkEnd - 1), endian)
    elements.add(element)
    chunkStart += chunkLen
  return elements
