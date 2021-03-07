extends Entity
class_name Player

signal player_moved(from, to)

func _input(event: InputEvent):
    var delta := Vector2.ZERO
    if event.is_action_pressed("ui_accept"):
        game.main.warp_cavern(2)
    elif event.is_action_pressed("ui_cancel"):
        pass
    elif event.is_action_pressed("ui_up", true):
        delta = Vector2(0, -1)
    elif event.is_action_pressed("ui_down", true):
        delta = Vector2(0, 1)
    elif event.is_action_pressed("ui_left", true):
        delta = Vector2(-1, 0)
    elif event.is_action_pressed("ui_right", true):
        delta = Vector2(1, 0)
    
    if delta != Vector2.ZERO:
        var test := zone_position + delta
        var ent: Entity = game.current_zone.get_entity(test)
        if ent:
            ent.bump()
        else:
            var from := zone_position
            move_to(test)
            emit_signal("player_moved", from, zone_position)

func _draw():
    draw_circle(Vector2(8, 8), 8, Color.red)
