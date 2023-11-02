import ./types
import constantine/math/arithmetic
import constantine/math/io/io_bigints

func unmarshal*(_: type F, bytes: openArray[byte]): F =
  assert bytes.len <= 31
  var padded: array[32, byte]
  copyMem(addr padded[0], unsafeAddr bytes[0], bytes.len)
  let bigint = B.unmarshal(padded, littleEndian)
  return F.fromBig(bigint)

func unmarshal*(_: type seq[F], bytes: openArray[byte]): seq[F] =
  const chunkLen = 31
  var elements: seq[F]
  var chunkStart = 0
  while chunkStart < bytes.len:
    let chunkEnd = min(chunkStart + 31, bytes.len)
    let element = F.unmarshal(bytes.toOpenArray(chunkStart, chunkEnd - 1))
    elements.add(element)
    chunkStart += chunkLen
  return elements
