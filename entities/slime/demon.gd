extends SlimeBase

signal demon_spotted()
signal finished_thinking()

const TELEPORT_CHANCE := 0.2
const THROW_CHANCE := 0.2

const HEALTH_MEDIAN := 18
const HEALTH_DEVIATION := 9

var seen := false

var health: int

func _ready() -> void:
    health = max(HEALTH_MEDIAN, Global.rng.randfn(HEALTH_MEDIAN, HEALTH_DEVIATION))
    print(health)

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
    elif (not brain.space.fog.is_revealed(map_position) and Global.rng.randf() < TELEPORT_CHANCE) or \
         (_dist_to_player() < 3 and Global.rng.randf() < TELEPORT_CHANCE * 2):
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
        
func _dist_to_player() -> float:
    var ppos = brain.space.player.map_position
    return map_position.distance_to(ppos)

func _teleport_near_player() -> void:
    var ppos = brain.space.player.map_position
    for i in 20:
        var found: Vector2 = brain.space.fog.random_revealed()
        if found != Vector2.ZERO and brain.space.is_free(found) and found.x != ppos.x and found.y != ppos.y and found.distance_to(ppos) >= 3:
            brain.move_slime(map_position, found)
            show()
            return

func _throw_fiend_near_player() -> void:
    for i in 20:
        var found: Vector2 = brain.space.fog.random_revealed()
        if found != Vector2.ZERO and brain.space.is_free(found):
            brain.grow_fiend(found)
            return
