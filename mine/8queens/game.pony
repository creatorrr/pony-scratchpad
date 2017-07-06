class Game
  let board: Board
  let size: USize = 8

  new create() =>
    // Initialize empty rows
    board = Board.create(size)

    var counter = size
    while counter > 0 do
      board.push(Row.create())
      counter = counter - 1
    end

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
    var surplus: USize = size - num_queens
    while surplus > 0 do
      board.push(Row.create())
      surplus = surplus - 1
    end

  fun ref play(pos: Pos) ? =>
    let playRow: Row = board(current_row())
    playRow.place(pos)

  fun blueprint(): Array[Pos] =>
    let bp: Array[Pos] = Array[Pos].create().>reserve(size)

    for row in board.values() do
      if row.is_taken() then
        let pos = row.where_queen()
        if pos < size then
          bp.push(pos)
        end
      end
    end

    bp.>trim_in_place(0, size)

  fun is_over(): Bool =>
    var result = true

    for row in board.values() do
      result = result and row.is_taken()
    end

    result

  fun current_row(): Pos =>
    var playingOnRow: Pos = 0

    for row in board.values() do
      if row.is_taken() then
        playingOnRow = playingOnRow + 1
      else break
      end
    end

    playingOnRow

  fun next_moves(): Array[Pos] =>
    let current: Pos = current_row()
    let moves: Array[Pos] = Array[Pos].create().>reserve(size)

    for (i, _) in board.pairs() do moves.push(i) end

    // Prune available moves
    for (i, row) in board.slice(0, current).pairs() do

      let queen_at: Pos = row.where_queen()

      // Find blocking positions
      let offset: Pos = current - size.min(i)

      let col: Pos = queen_at
      let p_diag: Pos = queen_at + offset
      let s_diag: Pos = queen_at - offset

      let to_remove = [col; p_diag; s_diag]

      for move in to_remove.values() do
        try moves.delete(moves.find(move)) end
      end
    end

    moves
