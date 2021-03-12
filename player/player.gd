extends Entity
class_name Player

func _unhandled_input(event: InputEvent) -> void:
    # Interact below us.
    if event.is_action_pressed("ui_accept"):
        Global.space.interact()
        return

    # Move.
    var delta := Vector2.ZERO
    if event.is_action_pressed("ui_up", true):
        delta = Vector2(0, -1)
    elif event.is_action_pressed("ui_down", true):
        delta = Vector2(0, 1)
    elif event.is_action_pressed("ui_left", true):
        delta = Vector2(-1, 0)
    elif event.is_action_pressed("ui_right", true):
        delta = Vector2(1, 0)

    if delta != Vector2.ZERO:
        var desired := map_position + delta
        Global.space.move_player(desired)
        return

    match event.get_class():
        "InputKeyEvent":
            var key := event as InputEventKey
            match key.scancode:
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
    map_position = value
    position = (value * 16) + Vector2(0, 1)
