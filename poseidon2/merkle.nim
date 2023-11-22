import constantine/math/arithmetic
import constantine/math/io/io_fields
import ./types
import ./io
import ./compress

const KeyNone = F.fromHex("0x0")
const KeyBottomLayer = F.fromHex("0x1")
const KeyOdd = F.fromHex("0x2")
const KeyOddAndBottomLayer = F.fromhex("0x3")

type Merkle* = object
  todo: seq[F] # nodes that haven't been combined yet
  width: int # width of the current subtree
  leafs: int # amount of leafs processed

func init*(_: type Merkle): Merkle =
  Merkle(width: 2)

func compress(merkle: var Merkle, odd: static bool) =
  when odd:
    let a = merkle.todo.pop()
    let b = zero
    let key = if merkle.width == 2: KeyOddAndBottomLayer else: KeyOdd
    merkle.todo.add(compress(a, b, key = key))
    merkle.leafs += merkle.width div 2 # zero node represents this many leafs
  else:
    let b = merkle.todo.pop()
    let a = merkle.todo.pop()
    let key = if merkle.width == 2: KeyBottomLayer else: KeyNone
    merkle.todo.add(compress(a, b, key = key))
  merkle.width *= 2

func update*(merkle: var Merkle, element: F) =
  merkle.todo.add(element)
  inc merkle.leafs
  merkle.width = 2
  while merkle.width <= merkle.leafs and merkle.leafs mod merkle.width == 0:
    merkle.compress(odd = false)

func finish*(merkle: var Merkle): F =
  assert merkle.todo.len > 0, "merkle root of empty sequence is not defined"

  if merkle.leafs == 1:
    merkle.compress(odd = true)

  while merkle.todo.len > 1:
    if merkle.leafs mod merkle.width == 0:
      merkle.compress(odd = false)
    else:
      merkle.compress(odd = true)

  return merkle.todo[0]

func digest*(_: type Merkle, elements: openArray[F]): F =
  var merkle = Merkle.init()
  for element in elements:
    merkle.update(element)
  return merkle.finish()

func digest*(_: type Merkle, bytes: openArray[byte]): F =
  var merkle = Merkle.init()
  for element in bytes.elements(F):
    merkle.update(element)
  return merkle.finish()
