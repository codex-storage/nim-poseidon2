import std/unittest
import std/sequtils
import std/random
import constantine/math/arithmetic
import poseidon2/sponge
import poseidon2/merkle
import poseidon2/spongemerkle

suite "sponge - merkle root":

  const KB = 1024

  test "hashes chunks of data with sponge, and combines them in merkle root":
    let bytes = newSeqWith(64*KB, rand(byte))
    var merkle = Merkle.init()
    for i in 0..<32:
      let chunk = bytes[(i*2*KB)..<((i+1)*2*KB)]
      let digest = Sponge.digest(chunk, rate = 2)
      merkle.update(digest)
    let expected = merkle.finish()
    check bool(SpongeMerkle.digest(bytes, chunkSize = 2*KB) == expected)

  test "handles partial chunk at the end":
    let bytes = newSeqWith(63*KB, rand(byte))
    var merkle = Merkle.init()
    for i in 0..<31:
      let chunk = bytes[(i*2*KB)..<((i+1)*2*KB)]
      let digest = Sponge.digest(chunk, rate = 2)
      merkle.update(digest)
    let partialChunk = bytes[(62*KB)..<(63*KB)]
    merkle.update(Sponge.digest(partialChunk, rate = 2))
    let expected = merkle.finish()
    check bool(SpongeMerkle.digest(bytes, chunkSize = 2*KB) == expected)
