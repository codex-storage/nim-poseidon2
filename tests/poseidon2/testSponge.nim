import std/unittest
import std/sequtils

import constantine/math/io/io_fields
import constantine/math/arithmetic

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

suite "sponge":

  test "sponge with rate=1":
    for n in 0..7:
      var xs: seq[F]
      for i in 1..n:
        xs.add( toF(i) )
      let h = Sponge.digest(xs, rate = 1)
      check toDecimal(h) == expectedSpongeResultsRate1[n]

  test "sponge with rate=2":
    for n in 0..7:
      var xs: seq[F]
      for i in 1..n:
        xs.add( toF(i) )
      let h = Sponge.digest(xs, rate = 2)
      check toDecimal(h) == expectedSpongeResultsRate2[n]

  test "sponge with byte array as input":
    let bytes = toSeq 1'u8..80'u8
    let elements = toSeq bytes.elements(F)
    let expected = Sponge.digest(elements, rate = 2)
    check bool(Sponge.digest(bytes, rate = 2) == expected)
