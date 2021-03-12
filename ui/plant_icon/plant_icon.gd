extends Control

export(PlantArch.Kind) var kind := PlantArch.Kind.TREE

func _ready() -> void:
    get_child(kind).show()
