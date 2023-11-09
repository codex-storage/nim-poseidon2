import constantine/math/arithmetic

import poseidon2/types
import poseidon2/roundfun
import poseidon2/io

export toBytes

#-------------------------------------------------------------------------------

# the Poseidon2 permutation (mutable, in-place version)
proc permInplace*(x, y, z : var F) =
  linearLayer(x, y, z)
  for j in 0..3:
    externalRound(j, x, y, z)
  for j in 0..55:
    internalRound(j, x, y, z)
  for j in 4..7:
    externalRound(j, x, y, z)

# the Poseidon2 permutation
func perm*(xyz: S) : S =
  var (x,y,z) = xyz
  permInplace(x, y, z)
  return (x,y,z)

#-------------------------------------------------------------------------------

# sponge with rate=1 (capacity=2)
func spongeWithRate1*(xs: openArray[F]) : F =
  var s0 : F = zero
  var s1 : F = zero
  var s2 : F = toF(0x0301) ; s2 += twoToThe64        # domain separation IV := (2^64 + 256*t + r)

  for x in xs:
    s0 += x
    permInplace(s0,s1,s2)

  # padding
  s0 += one
  permInplace(s0,s1,s2)
  return s0

# sponge with rate=2 (capacity=1)
func spongeWithRate2*(xs: openArray[F]) : F =
  let a = low(xs)
  let b = high(xs)
  let n = b-a+1
  let halfn  : int  = n div 2

  var s0 : F = zero
  var s1 : F = zero
  var s2 : F = toF(0x0302) ; s2 += twoToThe64        # domain separation IV := (2^64 + 256*t + r)

  for i in 0..<halfn:
    s0 += xs[a+2*i  ]
    s1 += xs[a+2*i+1]
    permInplace(s0,s1,s2)

  if (2*halfn == n):
    # padding even input
    s0 += one
    s1 += zero
  else:
    # padding odd input
    s0 += xs[b]
    s1 += one

  permInplace(s0,s1,s2)
  return s0

#-------------------------------------------------------------------------------

# 2-to-1 compression
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

    var ys : seq[F]
    if not isOdd:
      ys = newSeq[F](halfn)
    else:
      ys = newSeq[F](halfn+1)

    for i in 0..<halfn:
      ys[i] = compress( xs[a+2*i], xs[a+2*i+1] )
    if isOdd:
      ys[halfn] = compress( xs[n], zero )

    return merkleRoot(ys)

func merkleRoot*(bytes: openArray[byte]): F =
  merkleRoot(seq[F].fromBytes(bytes))

#-------------------------------------------------------------------------------
