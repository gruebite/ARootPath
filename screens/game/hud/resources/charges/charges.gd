extends Control

func _ready() -> void:
    deselect()

func change(kind: int, to: int) -> void:
    $NinePatch/MarginContainer/VBoxContainer.get_child(kind).get_node("Amount").text = str(to)
    
func select(kind: int) -> void:
    deselect()
    $NinePatch/MarginContainer/VBoxContainer.get_child(kind).get_node("Amount").modulate = Color.blue

func deselect() -> void:
    for node in $NinePatch/MarginContainer/VBoxContainer.get_children():
        node.get_node("Amount").modulate = Color.white
