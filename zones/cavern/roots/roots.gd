extends Entity

func bump() -> void:
    game.main.show_message(["Returning to the surface."], funcref(self, "_exit_cavern"))

func _exit_cavern() -> void:
    game.main.warp_island()
