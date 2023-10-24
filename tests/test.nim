
import std/math

import constantine/math/io/io_fields
import constantine/math/config/curves

import types
import posei2

#-------------------------------------------------------------------------------

var x: F = toF(0)
var y: F = toF(1)
var z: F = toF(2)

perm_inplace(x, y, z)

echo "\npermutation of (0,1,2):"
echo( toDecimal(x) )
echo( toDecimal(y) )
echo( toDecimal(z) )

#---------------------------------------

let m = 17
let n = 2^m
var xs: seq[F]
for i in 1..n:
  xs.add( toF(i) )

echo("\nmerkle root of ",1,"..",n,":")
let root = merkle_root(xs)
echo( toHex(root) )

