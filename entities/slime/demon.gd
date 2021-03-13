extends SlimeBase

const TELEPORT_CHANCE := 0.3
const THROW_CHANCE := 0.1

signal finished_thinking()

var seen := false

var health := 9

func think() -> void:
    # Don't think unless we've been seen, then all hell breaks loss.
    if not seen and not brain.space.fog.is_revealed(map_position): 
        emit_signal("finished_thinking")
        hide()
        return
    show()
    seen = true
    
    if Global.rng.randf() < TELEPORT_CHANCE:
        _teleport_near_player()
    elif Global.rng.randf() < THROW_CHANCE:
        _throw_fiend_near_player()
    else:
        # ??? scream?
        pass
    emit_signal("finished_thinking")

func damage() -> void:
    health -= 1
    if health <= 0:
        emit_signal("died")
        get_tree().change_scene("res://screens/win/win.tscn")

func _teleport_near_player() -> void:
    for i in 10:
        var found: Vector2 = brain.space.fog.random_revealed()
        if found != Vector2.ZERO and brain.space.is_free(found):
            brain.move_slime(map_position, found)
            return

func _throw_fiend_near_player() -> void:
    for i in 20:
        var found: Vector2 = brain.space.fog.random_revealed()
        if found != Vector2.ZERO and brain.space.is_free(found):
            brain.grow_fiend(found)
            return
