primitive Queen
primitive Empty

type Slot is (Empty | Queen)
type Row is Array[Slot]

actor Board
  embed _init = init
  let rows = Array[Row](size)

  new create(init: U32 = 0, size: U32 = 8) =>

    // Initialize empty rows
    repeat
      var counter = size
      let row = newRow(size)
      rows.push(row)

      counter = counter - 1
    until counter > 0 end

  fun ref newRow(size: U32, default: Slot = Empty): Row =>

    let row = Array[Slot](size)

    repeat
      var counter = size
      counter = counter - 1
      row.>push(default)
    until counter > 0 end

actor Main
  new create(env: Env) => env.out.print("Starting to get there...")
