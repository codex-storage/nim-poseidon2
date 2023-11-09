import ./types
import ./permutation
import constantine/math/io/io_fields
import constantine/math/arithmetic

type
  Sponge*[rate: static int] = object
    s0: F
    s1: F
    s2: F
    when rate == 2:
      even: bool

func init(sponge: var Sponge[1]) =
  # domain separation IV := (2^64 + 256*t + r)
  const IV = F.fromHex("0x10000000000000301")
  sponge.s0 = zero
  sponge.s1 = zero
  sponge.s2 = IV

func update*(sponge: var Sponge[1], element: F) =
  sponge.s0 += element
  permInPlace(sponge.s0, sponge.s1, sponge.s2)

func finish*(sponge: var Sponge[1]): F =
  # padding
  sponge.s0 += one
  permInPlace(sponge.s0, sponge.s1, sponge.s2)
  return sponge.s0

func init(sponge: var Sponge[2]) =
  # domain separation IV := (2^64 + 256*t + r)
  const IV = F.fromHex("0x10000000000000302")
  sponge.s0 = zero
  sponge.s1 = zero
  sponge.s2 = IV
  sponge.even = true

func update*(sponge: var Sponge[2], element: F) =
  if sponge.even:
    sponge.s0 += element
  else:
    sponge.s1 += element
    permInPlace(sponge.s0, sponge.s1, sponge.s2)
  sponge.even = not sponge.even

func finish*(sponge: var Sponge[2]): F =
  if sponge.even:
    # padding even input
    sponge.s0 += one
    sponge.s1 += zero
  else:
    # padding odd input
    sponge.s1 += one
  permInPlace(sponge.s0, sponge.s1, sponge.s2)
  return sponge.s0

func init*(_: type Sponge, rate: static int = 2): Sponge[rate] =
  when rate notin {1, 2}:
    {.error: "only rate 1 and 2 are supported".}
  result.init

func digest*(_: type Sponge, elements: openArray[F], rate: static int = 2): F =
  var sponge = Sponge.init(rate)
  for element in elements:
    sponge.update(element)
  return sponge.finish()

func digest*(_: type Sponge, bytes: openArray[byte], rate: static int = 2): F =
  var sponge = Sponge.init(rate)
  for element in bytes.elements(F):
    sponge.update(element)
  return sponge.finish()
