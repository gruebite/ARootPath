extends Control

func _ready() -> void:
    link_chains()
    
func link_chains(amount: int=0) -> void:
    for node in get_children():
        if node.get_index() < amount:
            node.show()
        else:
            node.hide()
