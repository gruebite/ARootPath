extends Entity
class_name Player

var facing := Direction.NORTH

func _unhandled_input(event: InputEvent) -> void:
    if $Tween.is_active() or $Water.playing or $AnimationPlayer.current_animation != "": return
    # Interact below us.
    if event.is_action_pressed("ui_accept"):
        Global.space.interact()
        return

    # Move.
    var delta := Vector2.ZERO
    if event.is_action_pressed("ui_up", true):
        facing = Direction.NORTH
        delta = Vector2(0, -1)
    elif event.is_action_pressed("ui_down", true):
        facing = Direction.SOUTH
        delta = Vector2(0, 1)
    elif event.is_action_pressed("ui_left", true):
        facing = Direction.WEST
        delta = Vector2(-1, 0)
    elif event.is_action_pressed("ui_right", true):
        facing = Direction.EAST
        delta = Vector2(1, 0)
    elif event is InputEventKey and event.pressed and event.scancode == KEY_PERIOD:
        # Debug wait.
        Global.space.move_player(map_position)
        return

    if delta != Vector2.ZERO:
        var desired := map_position + delta
        Global.space.move_player(desired)
        return

    if event is InputEventKey and event.pressed:
        match event.scancode:
            KEY_1:
                Global.space.interact(0)
            KEY_2:
                Global.space.interact(1)
            KEY_3:
                Global.space.interact(2)
            KEY_4:
                Global.space.interact(3)
            KEY_5:
                Global.space.interact(4)

func set_map_position(value: Vector2) -> void:
    map_position = value.floor()
    position = (value * 16) + Vector2(0, 1)

func be_water(purify: bool=false) -> void:
    if purify:
        $Purify.play()
    else:
        $Droplet.play()
    $Sprite.hide()
    $Shadow.hide()
    $Water.show()
    $Water.frame = 0
    $Water.play()
    yield($Water, "animation_finished")
    $Water.playing = false
    $Water.hide()
    $Sprite.show()
    $Shadow.show()

func consume_anim() -> void:
    $AnimationPlayer.play("consume")
    yield($AnimationPlayer, "animation_finished")
    return
