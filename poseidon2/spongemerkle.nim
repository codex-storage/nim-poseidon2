import ./types
import ./merkle
import ./sponge

type SpongeMerkle* = object
  merkle: Merkle

func init*(_: type SpongeMerkle): SpongeMerkle =
  SpongeMerkle(merkle: Merkle.init())

func update*(spongemerkle: var SpongeMerkle, chunk: openArray[byte]) =
  let digest = Sponge.digest(chunk, rate = 2)
  spongemerkle.merkle.update(digest)

func finish*(spongemerkle: var SpongeMerkle): F =
  return spongemerkle.merkle.finish()

func digest*(_: type SpongeMerkle, bytes: openArray[byte], chunkSize: int): F =
  ## Hashes chunks of data with a sponge of rate 2, and combines the
  ## resulting chunk hashes in a merkle root.
  var spongemerkle = SpongeMerkle.init()
  var index = 0
  while index < bytes.len:
    let start = index
    let finish = min(index + chunkSize, bytes.len)
    spongemerkle.update(bytes.toOpenArray(start, finish - 1))
    index += chunkSize
  return spongemerkle.finish()
