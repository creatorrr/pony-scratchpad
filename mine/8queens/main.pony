primitive Queen
primitive Empty

type Slot is (Empty | Queen)
type Board is Array[Row]

class Row
  let size: USize = 8
  let _this: Array[Slot]

  new create() =>
    _this = Array[Slot].init(Empty, size)

  new init(queen_at: USize = 0) ? =>
    _this = Array[Slot].init(Empty, size)
    _this.update(queen_at, Queen)

  fun is_taken(): Bool => _this.contains(Queen)
  fun where_queen(): USize ? => _this.find(Queen)

  fun ref place(pos: USize) ? =>
    if is_taken() then
      error
    end

    _this.update(pos, Queen)

class Game
  let board: Board
  let size: USize = 8

  new create() =>
    // Initialize empty rows
    let emptyRow: Row = Row.create()
    board = Board.init(emptyRow, size)

  new init(queens_at: Array[USize] ref) ? =>
    let num_queens: USize = queens_at.size()

    if num_queens > size then
      error
    end

    // Add rows
    board = Board.create(size)

    for queen_at in queens_at.values() do
      let row = Row.init(queen_at)
      board.push(row)
    end

    // Add empty rows at end
    let surplus: USize = size - num_queens
    let emptyRow: Row = Row.create()
    let extraRows: Array[Row] = Array[Row].init(emptyRow, surplus)

    board.concat(extraRows.values())

  fun is_over(): Bool =>
    var result = true

    for row in board.values() do
      result = result and row.is_taken()
    end
    result

  fun nextMoves(): Array[USize] =>
    let moves: Array[USize] = [0; 1; 2; 3; 4; 5; 6; 7]

    try
      let current: USize = currentRow()

      // Prune available moves
      for (i, row) in board.slice(0, current).pairs() do

        let queen_at: USize = row.where_queen()

        // Remove column-blocking positions
        try
          let col: USize = moves.find(queen_at)
          moves.remove(col, 1)
        end

        // Remove diag-blocking positions
        let offset: USize = current - size.min(i)
        let pDiag: USize = queen_at + offset
        let sDiag: USize = queen_at - offset

        try
          let pos: USize = moves.find(pDiag)
          moves.remove(pos, 1)
        end

        try
          let pos: USize = moves.find(sDiag)
          moves.remove(pos, 1)
        end
      end
    end

    moves

  fun currentRow(): USize ? =>
    var playingOnRow: USize = 0
    let iter = board.values()

    while iter.next().is_taken() do
      playingOnRow = playingOnRow + 1
    end

    playingOnRow

actor Main
  new create(env: Env) =>
    try
      let positions: Array[USize] = [1; 3]
      let game: Game = Game.init(positions)

      env.out.print("Starting to get there...")

      for pos in game.nextMoves().values() do
        env.out.print(pos.string())
      end
    end
