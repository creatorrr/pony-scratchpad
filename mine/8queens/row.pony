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
