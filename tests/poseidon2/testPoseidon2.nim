import std/unittest
import std/math
import std/sequtils

import constantine/math/arithmetic
import constantine/math/io/io_fields
import constantine/math/io/io_bigints
import constantine/serialization/codecs

import poseidon2/types
import poseidon2

#-------------------------------------------------------------------------------

const expectedSpongeResultsRate1 : array[8, string] = 
  [ "11474111961551684932675539562074905375756669035986300321099733737886849683321"
  , "12075737409606154890751050839468327529267137715708285489737384891841319770833"
  , "01607478768131843313297310704782442615640380643931196052095347138434114571392"
  , "17583439011341576528906247721476731129932611848439423516301689821385840105693"
  , "12983779044863516108508991186638610589212096523915590215701244866830295506005"
  , "16646216251577650555646508049064625507758601195307236539843683725095763921505"
  , "11914716034377431890952169039751213443286692885071871704776127977841051829452"
  , "20798492850731331785912281726856492405884190236464781409482377236764537088662"
  ]

const expectedSpongeResultsRate2 : array[8, string] = 
  [ "15335097698975718583905618186682475632756177170667436996250626760551196078076"
  , "05101758095924000127790537496504070769319625501671400349336709520206095219618"
  , "07306734450287348725566606192910189982345130476287345231433021147457815478255"
  , "18511919414269811073023003336929505285555117419480831606637506641708579940507"
  , "17917165106036607360653786499368288558581739128065811663709392730081030901634"
  , "04630821736691665506072583795473163860465039714428126246168623896083265248907"
  , "02020506076765964149531002674962673761843846094901604358961533722934321735239"
  , "11732533243633999579592740965735640217427639382365959787508754341969556105663"
  ]

#-------------------------------------------------------------------------------

suite "poseidon2":

  test "permutation in place":
    var x: F = toF(0)
    var y: F = toF(1)
    var z: F = toF(2)

    permInplace(x, y, z)

    check toDecimal(x) == "21882471761025344482456282050943515707267606647948403374880378562101343146243"
    check toDecimal(y) == "09030699330013392132529464674294378792132780497765201297316864012141442630280"
    check toDecimal(z) == "09137931384593657624554037900714196568304064431583163402259937475584578975855"

  test "sponge with rate=1":
    for n in 0..7:
      var xs: seq[F]
      for i in 1..n:
        xs.add( toF(i) )
      let h = spongeWithRate1(xs)
      check toDecimal(h) == expectedSpongeResultsRate1[n] 

  test "sponge with rate=2":
    for n in 0..7:
      var xs: seq[F]
      for i in 1..n:
        xs.add( toF(i) )
      let h = spongeWithRate2(xs)
      check toDecimal(h) == expectedSpongeResultsRate2[n] 

  test "merkle root of field elements":
    let m = 17
    let n = 2^m
    var xs: seq[F]
    for i in 1..n:
      xs.add( toF(i) )

    let root = merkleRoot(xs)
    check root.toHex(littleEndian) == "0xd1111b3515a663bb48278bfe453fe2508487014a1c6093d3ec5a6db764bbab1e"

  test "merkle root of even elements":
    let elements = toSeq(1..4).mapIt(toF(it))
    let expected = compress(compress(1.toF, 2.toF), compress(3.toF, 4.toF))
    check bool(merkleRoot(elements) == expected)

  test "merkle root of odd elements":
    let elements = toSeq(1..3).mapIt(toF(it))
    let expected = compress(compress(1.toF, 2.toF), compress(3.toF, 0.toF))
    check bool(merkleRoot(elements) == expected)

  test "merkle root of bytes":
    let bytes = toSeq 1'u8..80'u8
    let root = merkleRoot(bytes)
    check root.toHex(littleEndian) == "0xa1dffa3f60d166283d60396023d95a1d7996d119e5290fe31131e7c6a7a27817"

  test "merkle root of bytes converted to bytes":
    let bytes = toSeq 1'u8..80'u8
    let rootAsBytes = merkleRoot(bytes).toBytes()
    check rootAsBytes.toHex == "0xa1dffa3f60d166283d60396023d95a1d7996d119e5290fe31131e7c6a7a27817"
