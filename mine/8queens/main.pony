primitive Queen
primitive Empty

type Slot is (Empty | Queen)
type Board is Array[Row]

class Row
  let _this: Array[Slot]

  new init(from: Slot = Empty, len: USize = 8) =>
    _this = Array[Slot].init(from, len)

  fun is_taken(): Bool =>
    var result = false

    for pos in _this.values() do
      result = result or not (pos is Empty)
    end
    result

  fun where_queen(): USize ? => _this.find(Queen)

actor Game
  let _init: U32
  let board: Board

  new create(init: U32 = 0, size: USize = 8) =>
    _init = init

    // Initialize empty rows
    let emptyRow: Row = Row.init(Empty, size)
    board = Board.init(emptyRow, size)

  fun is_over(): Bool =>
    var result = true

    for row in board.values() do
      result = result and row.is_taken()
    end
    result

  // be placeNext

actor Main
  new create(env: Env) => env.out.print("Starting to get there...")
