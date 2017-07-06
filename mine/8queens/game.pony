class Game
  let board: Board
  let size: USize = 8

  new create() =>
    // Initialize empty rows
    let emptyRow: Row = Row.create()
    board = Board.init(emptyRow, size)

  new init(queens_at': Array[Pos] val) =>
    let queens_at = queens_at'.trim(0, size)
    let num_queens: USize = queens_at.size()

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

  fun ref play(pos: Pos) =>
    try
      let playRow: Row = board(current_row())
      playRow.place(pos)
    end

  fun blueprint(): Array[Pos] =>
    let bp: Array[Pos] = Array[Pos].create().>reserve(size)
    for row in board.values() do
      try
        bp.push(row.where_queen())
      end
    end

    bp

  fun is_over(): Bool =>
    var result = true

    for row in board.values() do
      result = result and row.is_taken()
    end
    result

  fun current_row(): Pos ? =>
    var playingOnRow: Pos = 0
    let iter = board.values()

    while iter.next().is_taken() do
      playingOnRow = playingOnRow + 1
    end

    playingOnRow

  fun next_moves(): Array[Pos] =>
    var current: Pos
    let moves: Array[Pos] = Array[Pos].create().>reserve(size)
    for (i, _) in board.pairs() do moves.push(i) end

    current = try current_row() else 0 end

    // Prune available moves
    for (i, row) in board.slice(0, current).pairs() do

      var queen_at: Pos = 0

      try
        queen_at = row.where_queen()
      else
        continue
      end

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

    moves
