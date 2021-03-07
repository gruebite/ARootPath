extends Entity

func bump() -> void:
    game.main.text_layer.show_with(["Entering cavern..."], funcref(self, "_enter_cavern"))

func _enter_cavern() -> void:
    game.main.warp_cavern(0)
