extends Control

export(Plant.Kind) var kind := Plant.Kind.TREE

func _ready() -> void:
    get_child(kind).show()
