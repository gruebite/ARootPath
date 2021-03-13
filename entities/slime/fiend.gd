extends SlimeBase

const THROW_CHANCE := 0.1

signal finished_thinking()

var health := 3

func think() -> void:
    # Don't think unless visible player.
    if not brain.space.fog.is_revealed(map_position): return
    
    if Global.rng.randf() < THROW_CHANCE:
        _throw_slime_near_player()
        
    emit_signal("finished_thinking")

func damage() -> void:
    health -= 1
    if health <= 0:
        emit_signal("died")

func _throw_slime_near_player() -> void:
    for i in 20:
        var found: Vector2 = brain.space.fog.random_revealed()
        if found != Vector2.ZERO and brain.space.is_free(found):
            brain.grow_slime(found)
            return
