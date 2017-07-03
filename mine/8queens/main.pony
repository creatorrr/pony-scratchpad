// An actor is a bit like a class in Python, Java etc.
// The difference between an actor and a class is that an actor can have asynchronous methods, called behaviours.
actor Main

  // This is a constructor.
  // The keyword new means it's a function that creates a new instance of the type.
  // Unlike other languages, constructors in Pony have names. That means there can be more than one way to construct an instance of a type. In this case, the name of the constructor is create
  new create(env: Env) =>

    // What's an Env, anyway? It's the "environment" your program was invoked with.
    // Pony has no global variables, so these things are explicitly passed to your program.

    env.out.print("nope, this is still not an 8queens solution")


// The Pony type system offers a lot of guarantees, even more than other statically typed languages.

  // - If your program compiles, it won't crash.
  // - There will never be an unhandled exception.
  // - There's no such thing as null, so your program will never try to dereference null.
  // - There will never be a data race.
  // - Your program will never deadlock.
  // - Your code will always be capabilities-secure.
  // - All message passing is causal.
