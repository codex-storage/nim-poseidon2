import ./types
import ./permutation

# 2-to-1 compression
func compress*(a, b : F) : F =
  var x = a
  var y = b
  var z : F = zero
  permInplace(x, y, z)
  return x
