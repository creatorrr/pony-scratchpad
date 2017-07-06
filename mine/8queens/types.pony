primitive Queen
primitive Empty

type Pos is USize
type Slot is (Empty | Queen)
type Board is Array[Row]
type Callback is {(Array[Game] iso)}
