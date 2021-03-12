extends Control

func _ready() -> void:
    deselect()

func change(kind: int, to: int) -> void:
    var idx := kind * 2
    var node = get_child(idx).get_node("MarginContainer/HBoxContainer/Label")
    node.text = str(to)
    
func select(kind: int, sub: int=-1) -> void:
    deselect()
    get_child(kind * 2).self_modulate = Color.blue
    if sub >= 0:
        var node := get_child(kind * 2 + 1)
        node.modulate = Color.white
        sub %= node.get_child_count()
        node.get_child(sub).self_modulate = Color.blue
    
func deselect() -> void:
    for i in get_child_count():
        if i % 2 == 0:
            get_child(i).self_modulate = Color.white
        if i % 2 == 1:
            get_child(i).modulate = Color.transparent
            for node in get_child(i).get_children():
                node.modulate = Color.white
