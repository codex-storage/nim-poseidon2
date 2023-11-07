import
  constantine/math/arithmetic,
  constantine/math/config/curves

import ./types
import ./roundconst

#-------------------------------------------------------------------------------

const externalRoundConst : array[24, F] = arrayFromHex( externalRoundConstStr )
const internalRoundConst : array[56, F] = arrayFromHex( internalRoundConstStr )

#-------------------------------------------------------------------------------

# inplace sbox, x => x^5
func sbox*(x: var F) : void =
  var y = x
  square(y)
  square(y)
  x *= y

func linearLayer*(x, y, z : var F) =
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

func internalRound*(j: int; x, y, z: var F) =
  x += internalRoundConst[j]
  sbox(x)
  var s = x ; s += y ;  s += z
  double(z)
  x += s
  y += s
  z += s

func externalRound*(j: int; x, y, z : var F) =
  x += externalRoundConst[3*j+0]
  y += externalRoundConst[3*j+1]
  z += externalRoundConst[3*j+2]
  sbox(x) ; sbox(y) ; sbox(z)
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

#-------------------------------------------------------------------------------

