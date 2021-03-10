extends NinePatchRect

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, rect_size), Color.transparent)
    draw_rect(Rect2(Vector2(0, 2), Vector2(owner.current_water, rect_size.y - 4)), Color.blue)
