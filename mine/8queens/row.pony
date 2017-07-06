class Row
  let size: USize = 8
  let _this: Array[Slot]

  new create() =>
    _this = Array[Slot].init(Empty, size)

  new init(queen_at: Pos = 0) =>
    _this = Array[Slot].init(Empty, size)

    try _this.update(queen_at, Queen) end

  fun ref place(pos: Pos) ? =>
    if is_taken() then error
    else _this.update(pos, Queen)
    end

  fun is_taken(): Bool => _this.contains(Queen)

  fun where_queen(): Pos =>
    try _this.find(Queen) else size end

  fun clone(): Row => Row.init(where_queen())
