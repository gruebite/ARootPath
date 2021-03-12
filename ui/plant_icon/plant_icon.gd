extends Control

const COLORS := [
    Color("#ff00ff"),
    Color("#00ffff"),
    Color("#ffff00"),
    Color("#ff0000"),
    Color("#ffffff"),
]

export(Plant.Kind) var kind := Plant.Kind.TREE

func _ready() -> void:
    get_child(kind).show()
    unhighlight()

func highlight() -> void:
    get_child(kind).modulate = COLORS[kind]

func unhighlight() -> void:
    get_child(kind).modulate = Color("#0000c0")
