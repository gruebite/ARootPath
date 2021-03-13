extends Particles2D

const SPEED := 64
const NEAR := 8

func _process(delta: float) -> void:
    var dir: Vector2 = (Global.space.player.position - position).normalized()
    position += dir * delta * SPEED
    
    var dist: float = position.distance_to(Global.space.player.position)
    if dist <= NEAR:
        queue_free()
        GameState.modify_water(1)
