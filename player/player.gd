extends Entity
class_name Player

signal took_turn()

onready var tween := $tween

func _unhandled_input(event: InputEvent):
    if $tween.is_active():
        return
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
        var test := zone_position + delta
        var ent: Entity = zone.get_entity(test)
        if ent:
            ent.bump()
            emit_signal("took_turn")
        elif not zone.unwalkable(test):
            tween.interpolate_property(self, "zone_position",
                zone_position, test, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
            tween.start()
            yield(tween, "tween_all_completed")
            emit_signal("took_turn")

func _draw():
    draw_circle(Vector2(8, 8), 5, Color.red)

func bump() -> void:
    print("WHAT")
