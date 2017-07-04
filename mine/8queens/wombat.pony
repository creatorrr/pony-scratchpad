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

  // Sometimes it's convenient to set a field the same way for all constructors.
  var _thirst_level: U64 = 1

  // Constructors
  // Every constructor has to set every field in an object. If it doesn't, the compiler will give you an error.
  // Fields with defaults may be omitted
  new create(name': String) =>
    name = name'
    _hunger_level = 0

  new hungry(name': String, hunger': U64) =>
    name = name'
    _hunger_level = hunger'

  // Functions in Pony are like methods in Java.
  // They can have parameters like constructors do, and they can also have a result type (if no result type is given, it defaults to None)
  // The result of a function is the last expression
  fun hunger(): U64 => _hunger_level

  // ref keyword implies a reference capability.
  // It means the receiver, i.e. the object on which the set_hunger function is being called, has to be a ref type. A ref type is a reference type, meaning that the object is mutable.
  // The default receiver reference capability if none is specified is box, which means "I need to be able to read from this, but I won't write to it".
  fun ref set_hunger(to: U64 = 0): U64 => _hunger_level = to
    // IMPORTANT: returns OLD vALUE of _hunger_level!!!
    // read: https://tutorial.ponylang.org/types/classes.html

  // Finalisers are special functions.
  // The definition of a finaliser must be fun _final().
  // They are used for clean up code.
  fun _final() => None


 // Naming stuff
 // A Pony type, whether it's a class, actor, trait, interface, primitive, or type alias, must start with an uppercase letter
 // any method or variable, including parameters and fields, must start with a lowercase letter
 // underscores in a row or at the end of a name are not allowed
 // numbers may use single underscores inside as a separator
