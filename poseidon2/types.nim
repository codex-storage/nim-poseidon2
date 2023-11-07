
import
  constantine/math/arithmetic,
  constantine/math/io/io_fields,
  constantine/math/io/io_bigints,
  constantine/math/config/curves

#-------------------------------------------------------------------------------

type B* = BigInt[254]
type F* = Fr[BN254Snarks]
type S* = (F,F,F)

#-------------------------------------------------------------------------------

func getZero*() : F =
  var z : F
  setZero(z)
  return z

func getOne*() : F = 
  var y : F
  # y.fromUint(1'u32)       # WTF, why does this not compile ???
  y.fromHex("0x01")
  return y

# for some reason this one does not compile... ???
# (when actually called)
func toF*(a: int) : F =
  var y : F
  y.fromInt(a)
  return y

func hexToF*(s : string, endian: static Endianness = bigEndian) : F =
  let bigint = B.fromHex(s, endian)
  return F.fromBig(bigint)

func arrayFromHex*[N](
    inp: array[N, string],
    endian: static Endianness = bigEndian) : array[N, F] =
  var tmp : array[N, F]
  for i in low(inp)..high(inp):
    tmp[i] = hexToF(inp[i], endian)
  return tmp
