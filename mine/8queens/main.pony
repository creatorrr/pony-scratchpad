primitive Queen
primitive Empty

type Pos is USize
type Slot is (Empty | Queen)
type Board is Array[Row]
type Callback is {(Array[Game])}

class Row
  let size: USize = 8
  let _this: Array[Slot]

  new create() =>
    _this = Array[Slot].init(Empty, size)

  new init(queen_at: Pos = 0) =>
    _this = Array[Slot].init(Empty, size)

    try _this.update(queen_at, Queen) end

  fun is_taken(): Bool => _this.contains(Queen)
  fun where_queen(): Pos ? => _this.find(Queen)

  fun raw(): Array[Slot] =>
    let raw_this: Array[Slot] = Array[Slot].create(size)
    for slot in _this.clone().values() do
      raw_this.push(slot)
    end
    raw_this

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

  fun currentRow(): Pos ? =>
    var playingOnRow: Pos = 0
    let iter = board.values()

    while iter.next().is_taken() do
      playingOnRow = playingOnRow + 1
    end

    playingOnRow

  fun ref play(pos: Pos) =>
    try
      let playRow: Row = board(currentRow())
      playRow.place(pos)
    end

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

actor Broker
  let _solvers: Array[Solver]
  let _callbacks: Array[Callback]

  new create(start_poss': Array[Pos] iso) =>
    let start_poss: Array[Pos] = consume start_poss'
    _solvers = Array[Solver].create().>reserve(start_poss.size())

    // Anticipating only 1 callback for now
    _callbacks = Array[Callback].create().>reserve(1)

    for pos in start_poss.values() do
      let blueprint = recover iso
        let game: Game = Game.create().>play(pos)
        game.blueprint()
      end

      let solver: Solver = Solver.create(consume blueprint, this)

      _solvers.push(solver)
    end

  // fun solutions(): Array[Game] =>
  //   let games: Array[Game] = Array[Game].create().>reserve(96)

  //   for solver in _solvers.values() do
  //     games.push(solver.solution())
  //   end
  //
  //   games

  // fun finished() =>
  //   for fn in _callbacks.values() do
  //   end

  fun ref on_finished(f: Callback) =>
    _callbacks.push(f)

  be register(solver: Solver) =>
    // Add solver and start process
    _solvers.push(solver)
    solver.solve()

  be start() =>
    // Start solvers
    for solver in _solvers.values() do
      solver.solve()
    end

  be mark_done(solver: Solver) =>
    try
      _solvers.delete(
        _solvers.find(solver)
      )
    end

actor Solver
  let _broker: Broker
  let _game: Game

  new create(game_blueprint: Array[Pos] iso, broker: Broker) =>
    _broker = broker
    _game = Game.init(consume game_blueprint)

  // fun solution(): Game =>
  //   let blueprint': Array[Pos] = _game.blueprint()
  //   let blueprint: Array[Pos] iso = recover iso
  //     Array[Pos].create().>append(blueprint')
  //   end
  //   let game: Game = Game.init(consume blueprint)
  //   game

  be solve() => "hi"

actor Main
  new create(env: Env) =>
    let positions: Array[Pos] val = recover val [1; 3] end
    let game: Game = Game.init(positions)

    env.out.print("Starting to get there...")

    for pos in game.nextMoves().values() do
      env.out.print(pos.string())
    end
