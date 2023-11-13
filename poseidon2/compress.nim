import ./types
import ./permutation

# 2-to-1 compression
func compress*(a, b : F, key = zero) : F =
  var x = a
  var y = b
  var z = key
  permInplace(x, y, z)
  return x
