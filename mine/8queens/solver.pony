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
