actor Solver
  let _broker: Broker
  let _game: Game

  new create(game_blueprint: Array[Pos] iso, broker: Broker) =>
    _broker = broker
    _game = Game.init(consume game_blueprint)

  fun ref game(): Game => _game
  fun ref done(): Bool => _game.is_over()
  fun solution(): Array[Pos] => _game.blueprint()

  be solve() =>
    let moves: Array[Pos] = _game.next_moves()

    try
      let next_move = moves.shift()
      _game.play(next_move)
    else
      signal_done(); return
    end

    for move in moves.values() do
      fork(move)
    end

    if done() then
      signal_done(); return
    else
      solve()
    end

  be signal_done() =>
    let blueprint: Array[Pos] iso = recover iso Array[Pos].create(8) end
    for pos in solution().values() do
      blueprint.push(pos)
    end

    if blueprint.size() == _game.size then
      _broker.mark_done(consume blueprint)
    end

  be fork(next: Pos) =>
    let blueprint: Array[Pos] iso = recover iso Array[Pos].create() end
    for pos in solution().values() do
      blueprint.push(pos)
    end

    blueprint.push(next)

    let new_solver = Solver.create(consume blueprint, _broker)
    _broker.register(new_solver)
