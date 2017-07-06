primitive Queen
primitive Empty

type Pos is USize
type Slot is (Empty | Queen)
type Board is Array[Row]
type Callback is {(Array[Game] iso)}

class Row
  let size: USize = 8
  let _this: Array[Slot]

  new create() =>
    _this = Array[Slot].init(Empty, size)

  new init(queen_at: Pos = 0) =>
    _this = Array[Slot].init(Empty, size)

    try _this.update(queen_at, Queen) end

  fun ref place(pos: Pos) ? =>
    if is_taken() then
      error
    end

    _this.update(pos, Queen)

  fun is_taken(): Bool => _this.contains(Queen)
  fun where_queen(): Pos ? => _this.find(Queen)

  fun raw(): Array[Slot] =>
    let raw_this: Array[Slot] = Array[Slot].create(size)
    for slot in _this.clone().values() do
      raw_this.push(slot)
    end
    raw_this

  fun clone(): Row =>
    try
      Row.init(where_queen())
    else
      Row.create()
    end


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


actor Solver
  let _broker: Broker
  let _game: Game

  new create(game_blueprint: Array[Pos] iso, broker: Broker) =>
    _broker = broker
    _game = Game.init(consume game_blueprint)

  fun ref game(): Game => _game
  fun ref done(): Bool => _game.is_over()

  be solve() =>
    if _game.is_over() then
      signal_done()
      return
    end

    let moves: Array[Pos] = _game.next_moves().clone()

    try
      _game.play(moves.shift())
    else
      _broker.print("Shit")
    end

    for move in moves.values() do
      var blueprint: Array[Pos] iso = recover iso Array[Pos].create(8) end
      for pos in _game.blueprint().values() do
        blueprint.push(pos)
      end

      blueprint.push(move)

      fork(consume blueprint)
    end

  be signal_done() =>
    let game_copy: Game iso = recover iso Game.create() end

    for pos in _game.blueprint().values() do
      game_copy.play(pos)
    end

    _broker.mark_done(consume game_copy)

  be fork(blueprint: Array[Pos] iso) =>
    let new_solver = Solver.create(consume blueprint, _broker)
    _broker.register(new_solver)


actor Broker
  let _solvers: Array[Solver]
  let _solutions: Array[Game]
  let _env: Env

  new create(env: Env, start_poss': Array[Pos] iso) =>
    let start_poss: Array[Pos] = consume start_poss'

    _env = env
    _solvers = Array[Solver].create().>reserve(start_poss.size())
    _solutions = Array[Game].create().>reserve(96)

    for pos in start_poss.values() do
      let blueprint = recover iso
        let game: Game = Game.create().>play(pos)
        game.blueprint()
      end

      let solver: Solver = Solver.create(consume blueprint, this)

      _solvers.push(solver)
    end

  fun is_finished(): Bool =>
    (_solvers.size() > 0) and (_solutions.size() == _solvers.size())

  fun finished() =>
    print("Done!")

    let result: Array[String] = [
      "The total number of solutions is "; _solutions.size().string(); "!"
    ]

    print("".join(result))

  be start() =>
    // Start solvers
    for solver in _solvers.values() do
      solver.solve()
    end

  be register(solver: Solver) =>
    _env.out.print("Solver registered")

    // Add solver and start process
    _solvers.push(solver)
    solver.solve()

  be mark_done(game': Game iso) =>
    let game: Game = consume game'
    if game.is_over() then _solutions.push(game) end

    print("Solver done")
    print(",".join(game.blueprint()))

  be print(s: String) => _env.out.print(s)


actor Main
  new create(env: Env) =>
    let positions: Array[Pos] iso = recover iso
      [0; 1; 2; 3; 4; 5; 6; 7]
    end

    let broker: Broker = Broker.create(env, consume positions)

    env.out.print("Starting...")
    broker.start()
