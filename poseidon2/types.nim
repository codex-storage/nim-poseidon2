
import
  constantine/math/io/io_fields,
  constantine/math/arithmetic,
  constantine/math/config/curves

#-------------------------------------------------------------------------------

type B* = BigInt[254]
type F* = Fr[BN254_Snarks]
type S* = (F,F,F)

#-------------------------------------------------------------------------------

func getZero*() : F =
  var z : F
  setZero(z)
  return z

func toF*(a: int) : F =
  var y : F
  fromInt(y, a);
  return y

func hexToF*(s : string) : F =
  var y : F
  fromHex(y, s)
  return y

func arrayFromHex*[N]( inp: array[N, string]) : array[N, F] =
  var tmp : array[N, F]
  for i in low(inp)..high(inp):
    tmp[i] = hexToF( inp[i] )
  return tmp

#-------------------------------------------------------------------------------
