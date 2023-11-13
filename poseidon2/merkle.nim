import std/sequtils
import constantine/math/arithmetic
import ./types
import ./io
import ./compress

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
  merkleRoot(toSeq bytes.elements(F))
