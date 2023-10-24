
# import std/sugar

import
  constantine/math/arithmetic,
  constantine/math/io/io_fields,
  constantine/math/config/curves

import types
import roundconst

#-------------------------------------------------------------------------------

let zero : F = getZero()

let external_round_const : array[24, F] = arrayFromHex( external_round_const_str )
let internal_round_const : array[56, F] = arrayFromHex( internal_round_const_str )

#-------------------------------------------------------------------------------

# inplace sbox, x => x^5
proc sbox(x: var F) : void =
  var y = x
  square(y)
  square(y)
  x *= y

proc linear_layer(x, y, z : var F) =
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

proc internal_round(j: int; x, y, z: var F) =
  x += internal_round_const[j]
  sbox(x)
  var s = x ; s += y ;  s += z
  double(z)
  x += s 
  y += s
  z += s

proc external_round(j: int; x, y, z : var F) =
  x += external_round_const[3*j+0]
  y += external_round_const[3*j+1]
  z += external_round_const[3*j+2]
  sbox(x) ; sbox(y) ; sbox(z)
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

proc perm_inplace*(x, y, z : var F) =
  linear_layer(x, y, z);
  for j in 0..3:
    external_round(j, x, y, z)
  for j in 0..55:
    internal_round(j, x, y, z)
  for j in 4..7:
    external_round(j, x, y, z)

proc perm*(xyz: S) : S =
  var (x,y,z) = xyz
  perm_inplace(x, y, z)
  return (x,y,z)

#-------------------------------------------------------------------------------

proc compress*(a, b : F) : F =
  var x = a
  var y = b
  var z : F ; setZero(z)
  perm_inplace(x, y, z)
  return x

proc merkle_root*(xs: openArray[F]) : F = 
  let a = low(xs)
  let b = high(xs)
  let m = b-a+1

  if m==1:
    return xs[a]

  else:
    let halfn  : int  = m div 2
    let n      : int  = 2*halfn
    let is_odd : bool = (n != m)
  
    var ys : seq[F] = newSeq[F](halfn)

    if not is_odd:
      for i in 0..<halfn:
        ys[i] = compress( xs[a+2*i], xs[a+2*i+1] )

    else:
      for i in 0..<halfn-1:
        ys[i] = compress( xs[a+2*i], xs[a+2*i+1] )
      # and the last one:
      ys[halfn-1] = compress( xs[a+n-2], zero )

    return merkle_root(ys)

#-------------------------------------------------------------------------------
  


