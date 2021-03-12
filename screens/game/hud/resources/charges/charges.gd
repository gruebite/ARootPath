extends Control

func _ready() -> void:
    highlight()

func change(kind: int, to: int) -> void:
    $VBoxContainer.get_child(kind).get_node("Amount").text = str(to)
    
func highlight(kind: int=-1) -> void:
    for node in $VBoxContainer.get_children():
        if kind == -1 or node.get_index() == kind:
            node.get_node("Amount").modulate = Color.white
            node.get_node("PlantIcon").highlight()
        else:
            node.get_node("Amount").modulate = Color("#0000c0")
            node.get_node("PlantIcon").unhighlight()
