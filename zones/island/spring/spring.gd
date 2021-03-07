extends Entity

func bump() -> void:
    print("BUMP!")
    game.main.warp_cavern(0)
