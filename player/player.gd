extends Entity
class_name Player

func _unhandled_input(event: InputEvent):
    var delta := Vector2.ZERO
    if event.is_action_pressed("ui_accept"):
        game.main.warp_island()
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
        var ent: Entity = game.main.current_zone.get_entity_at(test)
        if ent:
            ent.bump()
        elif not game.main.current_zone.unwalkable(test):
            game.main.current_zone.move_entity(self, test)

func _draw():
    draw_circle(Vector2(8, 8), 8, Color.red)
