extends Sprite

func _input(event: InputEvent):
    match event.get_class():
        "InputEventKey":
            var key_event: InputEventKey = event
            if key_event.pressed:
                match key_event.scancode:
                    KEY_UP:
                        position.y -= 16
                    KEY_DOWN:
                        position.y += 16
                    KEY_LEFT:
                        position.x -= 16
                    KEY_RIGHT:
                        position.x += 16

func _draw():
    draw_circle(Vector2(0, 0), 8, Color.red)
