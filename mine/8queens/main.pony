actor Main
  new create(env: Env) =>
    let positions: Array[Pos] iso = recover iso
      [0; 1; 2; 3; 4; 5; 6; 7]
    end

    let broker: Broker = Broker.create(env, consume positions)

    env.out.print("Starting...")
    broker.start()
