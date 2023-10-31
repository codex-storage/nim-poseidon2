import ./types
import constantine/math/arithmetic
import constantine/math/io/io_bigints

proc unmarshal*(
        _: type F,
        bytes: openArray[byte],
        endian: static Endianness): seq[F] =
  const chunkLen = 31
  var elements: seq[F]
  var i = 0
  while i < bytes.len:
    let chunk = bytes[i..<min(i + chunkLen, bytes.len)]
    let bigint = B.unmarshal(chunk, endian)
    let element = F.fromBig(bigint)
    elements.add(element)
    i += chunkLen
  return elements
