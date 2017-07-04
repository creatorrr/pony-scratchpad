primitive Queen
primitive Empty

type Pos is USize
type Slot is (Empty | Queen)
type Board is Array[Row]

class Row
  let size: USize = 8
  let _this: Array[Slot]

  new create() =>
    _this = Array[Slot].init(Empty, size)

  new init(queen_at: Pos = 0) ? =>
    _this = Array[Slot].init(Empty, size)
    _this.update(queen_at, Queen)

  fun is_taken(): Bool => _this.contains(Queen)
  fun where_queen(): Pos ? => _this.find(Queen)

  fun ref place(pos: Pos) ? =>
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

  new init(queens_at: Array[Pos] ref) ? =>
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

  fun nextMoves(): Array[Pos] =>
    let moves: Array[Pos] = Array[Pos].create().>reserve(size)
    for (i, _) in board.pairs() do moves.push(i) end

    try
      let current: Pos = currentRow()

      // Prune available moves
      for (i, row) in board.slice(0, current).pairs() do

        let queen_at: Pos = row.where_queen()

        // Remove column-blocking positions
        try
          let col: Pos = moves.find(queen_at)
          moves.remove(col, 1)
        end

        // Remove diag-blocking positions
        let offset: Pos = current - size.min(i)
        let pDiag: Pos = queen_at + offset
        let sDiag: Pos = queen_at - offset

        try
          let pos: Pos = moves.find(pDiag)
          moves.remove(pos, 1)
        end

        try
          let pos: Pos = moves.find(sDiag)
          moves.remove(pos, 1)
        end
      end
    end

    moves

  fun currentRow(): Pos ? =>
    var playingOnRow: Pos = 0
    let iter = board.values()

    while iter.next().is_taken() do
      playingOnRow = playingOnRow + 1
    end

    playingOnRow

actor Solver
  new create(init: Pos) => "hi"

actor Main
  new create(env: Env) =>
    try
      let positions: Array[Pos] = [1; 3]
      let game: Game = Game.init(positions)

      env.out.print("Starting to get there...")

      for pos in game.nextMoves().values() do
        env.out.print(pos.string())
      end
    end
