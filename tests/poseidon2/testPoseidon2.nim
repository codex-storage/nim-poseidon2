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
  [ "12363515589665961836680709257448433057869762330741639517836048636244832188495"
  , "10755250120808789043370150604836786069442045362641800439807384337872752972068"
  , "04842014531366721455661330916203255410159059117951668762867230544004815370337"
  , "13502515636936876459766686836354199651004594178376827739246669803080321705927"
  , "19312121576697000598919845239663673946550934099828684806027699882665482322097"
  , "21509595983900483103260021285060939918324350560398732346653142062765920502059"
  , "11892726572958426459775026381831352388154613015696290329810000571844227402585"
  , "10284126944232604349630438079200913190801781418325975675236599364113149409058"
  ]

# TODO: add domain separation between rate=1 and rate=2, so that the empty input
# gives different results. But this has to be done in all the other Poseidon2 libraries
# too (circom, Haskell, C...)

const expectedSpongeResultsRate2 : array[8, string] = 
  [ "12363515589665961836680709257448433057869762330741639517836048636244832188495"
  , "00899009032366875286186953183805404053380636995610127460025486428583509745414"
  , "16500906802543951227422597869354004883060519121579073949799015758201044544012"
  , "05275430613748165078459451567241807462288293965310307668712900802458919462965"
  , "13763559248248167400098483085605230840597893317332127197498651878933380690961"
  , "14871143128308815290845020646262475973102494373985615216162863857354721038367"
  , "02746725081632011689597680224823496636241961292066939394613880404914874634920"
  , "02290144245981244996669076598332792758523446545263085369617640761875376727694"
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
      # echo(toDecimal(h))
      check toDecimal(h) == expectedSpongeResultsRate1[n] 

  test "sponge with rate=2":
    for n in 0..7:
      var xs: seq[F]
      for i in 1..n:
        xs.add( toF(i) )
      let h = spongeWithRate2(xs)
      # echo(toDecimal(h))
      check toDecimal(h) == expectedSpongeResultsRate2[n] 

  test "merkle root of field elements":
    let m = 17
    let n = 2^m
    var xs: seq[F]
    for i in 1..n:
      xs.add( toF(i) )

    let root = merkleRoot(xs)
    check root.toHex(littleEndian) == "0xd1111b3515a663bb48278bfe453fe2508487014a1c6093d3ec5a6db764bbab1e"

  test "merkle root of bytes":
    let bytes = toSeq 1'u8..80'u8
    let root = merkleRoot(bytes)
    check root.toHex(littleEndian) == "0x00f5c12fabdf0fce1a69b9f0920f60e0c0ea4d8a880ae297559e0ad2276f2d2d"

  test "merkle root of bytes converted to bytes":
    let bytes = toSeq 1'u8..80'u8
    let rootAsBytes = merkleRoot(bytes).toBytes()
    check rootAsBytes.toHex == "0x00f5c12fabdf0fce1a69b9f0920f60e0c0ea4d8a880ae297559e0ad2276f2d2d"
