"""
An actor behaviour is intended for short lived finite interactions executed
asynchronously. Sometimes it is useful to be able to naturally code behaviours
of short lived finite signals punctuating over a longer lived (but finite)
behaviour. In actor implementations that do not feature causal messaging this is
fairly natural and idiomatic. But in pony, without yield, this is impossible.

The causal messaging guarantee, and asynchronous execution means that the
messages enqueued in the actor's mailbox will never be scheduled for execution
if the receiving behaviour is infinite, which it can be in the worst case (bad
code).

By rediculo ad absurdum the simplest manifestation of this problem is a
signaling behaviour, say a 'kill' message, that sets a flag to conditionally
stop accepting messages. The runtime will only detect an actor as GCable if it
reaches quiescence *and* there are no pending messages waiting to be enqueued to
the actor in its mailbox. But, our 'kill' message can never proceed from the
mailbox as the currently active behaviour (infinite) never completes.

We call this the lonely pony problem. And, it can be solved in 0 lines of pony.

Yield in pony is a simple clever trick. By transforming loops in long running
behaviours to lazy tail-recursive behaviour calls composed, we can yield
conditionally whilst preserving causal messaging guarantees, and enforcing at-
most-once delivery semantics.

The benefits of causal messaging, garbage collectible actors, and safe mutable
actors far outweigh the small price manifested by the lonely pony problem. The
solution, that uncovered the consume apply idiom and its application to enable
interruptible behaviours that are easy to use are far more valuable at the cost
to the actor implementor of only a few extra lines of code per behaviour to
enable interruptible semantics with strong causal guarantees.

In a nutshell, by avoiding for and while loops, and writing behaviours tail
recursively, the ability to compose long-lived with short-lived behaviours is a
builtin feature of pony.
"""

use "cli"
use "collections"
use "debug"
use "time"

class StopWatch
  """
  A simple stopwatch class for performance micro-benchmarking
  """
  var _s: U64 = 0

  fun ref start(): StopWatch =>
    _s = Time.nanos()
    this

  fun delta(): U64 =>
    Time.nanos() - _s

actor LonelyPony
  """
  A simple manifestation of the lonely pony problem
  """
  var _env: Env
  let _sw: StopWatch = StopWatch
  var _alive: Bool = true
  var _debug: Bool = false
  var _m: U64
  var _n: U64

  new create(env: Env, debug: Bool = false, n: U64 = 0) =>
    _env = env
    _debug = debug
    _m = n
    _n = n

  be kill() =>
    if _debug then
      _env.out.print("Received kill signal!")
    end
    _alive = false

  be forever() =>
    """
    The trivial case of a badly written behaviour that eats a scheduler (forever)
    """
    while _alive do
      if _debug then
        _env.out.print("Beep boop!")
      end
    end

  be perf() =>
    var r = Range[U64](0,_n)
    _sw.start()
    for i in r do
      if _debug then
        _env.err.print("L:" + (_n - i).string())
      end
    end
    let d = _sw.delta()
    _env.out.print("N: " + _m.string() + ", Lonely: " + d.string())

actor InterruptiblePony
  """
  An interruptible version that avoids the lonely pony problem
  """
  var _env: Env
  let _sw: StopWatch = StopWatch
  var _alive: Bool = true
  var _debug: Bool = false
  var _n: U64

  new create(env: Env, debug: Bool, n: U64 = 0) =>
    _env = env
    _debug = debug
    _n = n

  be kill() =>
    if _debug then
      _env.err.print("Received kill signal!")
    end
    _alive = false

  be forever() =>
    match _alive
    | true =>
      Debug.err("Beep boop!")
      this.forever()
    | false =>
      Debug.err("Ugah!")
      None
    end

  be _bare_perf() =>
    match _n
    | 0 =>
      Debug.err("Ugah!")
      let d = _sw.delta()
      _env.out.print("N=" + _n.string() + ", Interruptible: " + d.string())
    else
      if _debug then
        _env.err.print("I: " + _n.string())
      end
      _n = _n - 1
      this._bare_perf()
    end

  be perf() =>
    _sw.start()
    _bare_perf()
    this

actor PunkDemo
  var _env: Env
  var _alive: Bool = false
  var _current: U8 = 0

  new create(env: Env) =>
    _env = env

  be inc() =>
    if _current < 255 then
      _current = _current + 1
    end
    print()

  be dec() =>
    if _current > 0 then
      _current = _current - 1
    end
    print()

  fun print() =>
    _env.out.print("Level: " + _current.string())

  be kill() =>
    _alive = false

  be loop() =>
    match _alive
    | true => this.loop()
    | false => _env.out.print("Done! ") ; None
    end

actor Main
  var _env: Env
  new create(env: Env) =>
    _env = env

    let cs = try
        CommandSpec.parent("yield",
        """
        Demonstrate use of the yield behaviour when writing tail recursive
        behaviours in pony.

        By Default, the actor will run quiet and interruptibly.""",
        [
        OptionSpec.bool("punk",
          "Run a punctuated stream demonstration."
          where short' = 'p', default' = false)
        OptionSpec.i64("bench",
          "Run an instrumented behaviour to guesstimate overhead of non/interruptive."
          where short' = 'b', default' = 0)
        OptionSpec.bool("lonely",
          "Run a non-interruptible behaviour with logic that runs forever."
          where short' = 'l', default' = false)
        OptionSpec.bool("debug", "Run in debug mode with verbose output."
          where short' = 'd', default' = false)
      ]).>add_help()
    else
      _env.exitcode(-1)  // some kind of coding error
      return
    end

    let cmd =
      match CommandParser(cs).parse(_env.args, _env.vars())
      | let c: Command => c
      | let ch: CommandHelp =>
        ch.print_help(_env.out)
        _env.exitcode(0)
        return
      | let se: SyntaxError =>
        _env.out.print(se.string())
        _env.exitcode(1)
        return
      end

    var punk: Bool = cmd.option("punk").bool()
    var perf: U64 = cmd.option("bench").i64().u64()
    var lonely: Bool = cmd.option("lonely").bool()
    var debug: Bool = cmd.option("lonely").bool()

    match punk
    | true =>
      PunkDemo(env)
        .>loop()
        .>inc().>inc().>inc()
        .>dec().>dec().>dec()
        .>inc().>dec()
        .>kill()
    else
      match perf > 0
      | true =>
        InterruptiblePony(env,debug,perf).perf()
        LonelyPony(env,debug,perf).perf()
      else
        match lonely
        | false => InterruptiblePony(env,debug).>forever().>kill()
        | true => LonelyPony(env,debug).>forever().>kill()
        end
      end
    end
