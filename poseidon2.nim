import
  constantine/math/arithmetic,
  constantine/math/config/curves

import poseidon2/types
import poseidon2/roundconst
import poseidon2/io

#-------------------------------------------------------------------------------

const zero : F = getZero()

const externalRoundConst : array[24, F] = arrayFromHex( externalRoundConstStr )
const internalRoundConst : array[56, F] = arrayFromHex( internalRoundConstStr )

#-------------------------------------------------------------------------------

# inplace sbox, x => x^5
func sbox(x: var F) : void =
  var y = x
  square(y)
  square(y)
  x *= y

func linearLayer(x, y, z : var F) =
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

func internalRound(j: int; x, y, z: var F) =
  x += internalRoundConst[j]
  sbox(x)
  var s = x ; s += y ;  s += z
  double(z)
  x += s
  y += s
  z += s

func externalRound(j: int; x, y, z : var F) =
  x += externalRoundConst[3*j+0]
  y += externalRoundConst[3*j+1]
  z += externalRoundConst[3*j+2]
  sbox(x) ; sbox(y) ; sbox(z)
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

func permInplace*(x, y, z : var F) =
  linearLayer(x, y, z);
  for j in 0..3:
    externalRound(j, x, y, z)
  for j in 0..55:
    internalRound(j, x, y, z)
  for j in 4..7:
    externalRound(j, x, y, z)

func perm*(xyz: S) : S =
  var (x,y,z) = xyz
  permInplace(x, y, z)
  return (x,y,z)

#-------------------------------------------------------------------------------

func compress*(a, b : F) : F =
  var x = a
  var y = b
  var z : F ; setZero(z)
  permInplace(x, y, z)
  return x

func merkleRoot*(xs: openArray[F]) : F =
  let a = low(xs)
  let b = high(xs)
  let m = b-a+1

  if m==1:
    return xs[a]

  else:
    let halfn  : int  = m div 2
    let n      : int  = 2*halfn
    let isOdd : bool = (n != m)

    var ys : seq[F] = newSeq[F](halfn)

    if not isOdd:
      for i in 0..<halfn:
        ys[i] = compress( xs[a+2*i], xs[a+2*i+1] )

    else:
      for i in 0..<halfn-1:
        ys[i] = compress( xs[a+2*i], xs[a+2*i+1] )
      # and the last one:
      ys[halfn-1] = compress( xs[a+n-2], zero )

    return merkleRoot(ys)

func merkleRoot*(bytes: openArray[byte]): F =
  merkleRoot(seq[F].unmarshal(bytes, littleEndian))
