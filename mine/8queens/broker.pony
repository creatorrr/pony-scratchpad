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
      let blueprint: Array[Pos] iso = recover iso
        let a = Array[Pos].create(1)
        a.>push(pos)
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

  be mark_done(solver: Solver) =>
    _solutions.push(solver.game)

    print("Solver done")
    print(",".join(solver.game.blueprint()))

  be print(s: String) => _env.out.print(s)