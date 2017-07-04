primitive Queen
primitive Empty

type Slot is (Empty | Queen)
type Row is Array[Slot]
type Board is Array[Row]

actor Solution
  let _init: U32
  let board: Board

  new create(init: U32 = 0, size: USize = 8) =>
    _init = init

    // Initialize empty rows
    let emptyRow: Row = Row.init(Empty, size)
    board = Board.init(emptyRow, size)

actor Main
  new create(env: Env) => env.out.print("Starting to get there...")
