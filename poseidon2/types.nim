
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

# Remark: since `fromInt()` does not work at compile time, this doesn't either
func toF*(a: int) : F =
  var y : F
  y.fromInt(a)
  return y

#-------------------------------------------------------------------------------

const zero* : F = getZero()
const one*  : F = fromHex(F,"0x01")     # note: `fromUint()` does not work at compile time

const twoToThe64* : F = fromHex(F,"0x10000000000000000")

#-------------------------------------------------------------------------------

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
