import std/sequtils
import constantine/math/arithmetic
import constantine/math/io/io_fields
import poseidon2/types
import poseidon2/io
import poseidon2/compress

const KeyNone = F.fromHex("0x0")
const KeyBottomLayer = F.fromHex("0x1")
const KeyOdd = F.fromHex("0x2")
const KeyOddAndBottomLayer = F.fromhex("0x3")

# Reference implementation of merkle root algorithm
# Only used in tests
func merkleRoot(xs: openArray[F], isBottomLayer: static bool) : F =
  let a = low(xs)
  let b = high(xs)
  let m = b-a+1

  when isBottomLayer:
    assert m > 0, "merkle root of empty sequence is not defined"

  when not isBottomLayer:
    if m==1:
      return xs[a]

  let halfn  : int  = m div 2
  let n      : int  = 2*halfn
  let isOdd : bool = (n != m)

  var ys : seq[F]
  if not isOdd:
    ys = newSeq[F](halfn)
  else:
    ys = newSeq[F](halfn+1)

  for i in 0..<halfn:
    const key = when isBottomLayer: KeyBottomLayer else: KeyNone
    ys[i] = compress( xs[a+2*i], xs[a+2*i+1], key = key )
  if isOdd:
    const key = when isBottomLayer: KeyOddAndBottomLayer else: KeyOdd
    ys[halfn] = compress( xs[n], zero, key = key )

  return merkleRoot(ys, isBottomLayer = false)

func merkleRoot*(xs: openArray[F]) : F =
  merkleRoot(xs, isBottomLayer = true)

func merkleRoot*(bytes: openArray[byte]): F =
  merkleRoot(toSeq bytes.elements(F))
