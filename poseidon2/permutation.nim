import ./types
import ./roundfun

# the Poseidon2 permutation (mutable, in-place version)
proc permInPlace*(x, y, z : var F) =
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
  permInPlace(x, y, z)
  return (x,y,z)
