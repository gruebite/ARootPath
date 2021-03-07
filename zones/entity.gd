extends Sprite
class_name Entity

var zone_position: Vector2 setget move_to

func move_to(value: Vector2) -> void:
    zone_position = value
    position = value * 16

func move_by(delta: Vector2) -> void:
    move_to(zone_position + delta)

func bump() -> void:
    pass
