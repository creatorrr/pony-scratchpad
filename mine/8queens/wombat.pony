// A class, it has to have a name that starts with a capital letter.
// A class is composed of:

  // - Fields.
  // - Constructors.
  // - Functions.
class Wombat

  // There are three kinds of fields: var, let, and embed fields. A var field can be assigned to over and over again, but a let field is assigned to in the constructor and never again.
  let name: String

  // A private field can only be accessed by code in the same type (class?).
  // A private constructor, function, or behaviour can only be accessed by code in the same package.
  var _hunger_level: U64

  // Constructors
  // Every constructor has to set every field in an object. If it doesn't, the compiler will give you an error.
  new create(name': String) =>
    name = name'
    _hunger_level = 0

  new hungry(name': String, hunger': U64) =>
    name = name'
    _hunger_level = hunger'
