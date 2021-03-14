extends Particles2D

const SPEED := 64
const NEAR := 4

const BURST_TIME := 0.2
const BURST_MULT := 3

var burst := 0.0
var bursting := true
var burst_dir := Vector2.ZERO

func _ready() -> void:
    burst_dir = Vector2.ONE.rotated(Global.rng.randf() * TAU)

func _process(delta: float) -> void:
    if bursting:
        position += burst_dir * delta * SPEED * BURST_MULT
        burst += delta
        if burst >= BURST_TIME:
            bursting = false
    else:
        var pos_center = Global.space.player.position + Vector2(8, 0)
        var dir: Vector2 = (pos_center - position).normalized()
        position += dir * delta * SPEED
        
        var dist: float = position.distance_to(pos_center)
        if dist <= NEAR:
            queue_free()
            GameState.modify_water(1)
