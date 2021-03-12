extends Control

func select(kind: int, subkind: int=0) -> void:
    deselect()
    var parent := get_child(kind)
    parent.show()
    for node in parent.get_node("NinePatch").get_children():
        if node.get_index() == subkind:
            node.modulate = Color.blue
        else:
            node.modulate = Color.white

func deselect() -> void:
    for node in get_children():
        node.hide()

