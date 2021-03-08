extends Entity

func bump() -> void:
    game.main.show_message(["Deeper..."], funcref(self, "_enter_cavern"))

func _enter_cavern() -> void:
    game.main.warp_cavern(game.main.current_zone.level + 1)
