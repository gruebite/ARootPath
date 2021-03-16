extends SlimeBase

signal demon_spotted()
signal finished_thinking()

const TELEPORT_CHANCE := 0.1
const THROW_CHANCE := 0.2

var seen := false

var health := 27

func think() -> void:
    # Don't think unless we've been seen, then all hell breaks loss.
    if not seen and not brain.space.fog.is_revealed(map_position): 
        emit_signal("finished_thinking")
        hide()
        return
    if not seen:
        emit_signal("demon_spotted")
    if brain.space.fog.is_revealed(map_position):
        show()
    else:
        hide()
    seen = true
    GameState.saw_demon = true

    if brain.space.fog.is_revealed(map_position) and Global.rng.randf() < THROW_CHANCE:
        $Throw.play()
        $AnimationPlayer.play("throw")
        yield($AnimationPlayer, "animation_finished")
        _throw_fiend_near_player()
        $AnimationPlayer.play("idle")
    elif Global.rng.randf() < TELEPORT_CHANCE:
        $Teleport.play()
        $AnimationPlayer.play("teleport_out")
        yield($AnimationPlayer, "animation_finished")
        _teleport_near_player()
        $AnimationPlayer.play("teleport_in")
        yield($AnimationPlayer, "animation_finished")
        $AnimationPlayer.play("idle")
    emit_signal("finished_thinking")

func damage() -> void:
    health -= 1
    poof()
    if health <= 0:
        get_tree().change_scene("res://screens/win/win.tscn")

func _teleport_near_player() -> void:
    for i in 10:
        var found: Vector2 = brain.space.fog.random_revealed()
        if found != Vector2.ZERO and brain.space.is_free(found) and found != brain.space.player.map_position:
            brain.move_slime(map_position, found)
            if brain.space.fog.is_revealed(found):
                show()
            return

func _throw_fiend_near_player() -> void:
    for i in 20:
        var found: Vector2 = brain.space.fog.random_revealed()
        if found != Vector2.ZERO and brain.space.is_free(found):
            brain.grow_fiend(found)
            return
