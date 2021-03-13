extends SlimeBase

const THROW_CHANCE := 0.1

signal finished_thinking()

var health := 3

func think() -> void:
    # Don't think unless visible player.
    if not brain.space.fog.is_revealed(map_position):
        emit_signal("finished_thinking")
        hide()
        return
    show()
    # The fiend does not throw stuff when frozen, the demon can still act.
    if frozen:
        emit_signal("finished_thinking")
        return
    
    if Global.rng.randf() < THROW_CHANCE:
        _throw_slime_near_player()
        
    emit_signal("finished_thinking")

func damage() -> void:
    health -= 1
    if health <= 0:
        emit_signal("died")

func _throw_slime_near_player() -> void:
    for i in 20:
        var x = brain.space.player.map_position.x - Global.rng.randi_range(-2, 2)
        var y = brain.space.player.map_position.y - Global.rng.randi_range(-2, 2)
        var check := Vector2(x, y)
        if brain.space.is_free(check):
            brain.grow_slime(check)
            return
