extends Particles2D

const SPEED := 128
const NEAR := 4

const WAIT_TIME := 0.3

var wait := 0.0

func _process(delta: float) -> void:
    if wait < WAIT_TIME:
        wait += delta
    else:
        var pos_center = Global.space.player.position + Vector2(8, 0)
        var dir: Vector2 = (pos_center - position).normalized()
        position += dir * delta * SPEED
        
        var dist: float = position.distance_to(pos_center)
        if dist <= NEAR:
            GameState.modify_water(1)
            queue_free()
