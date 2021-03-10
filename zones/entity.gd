extends Sprite
class_name Entity

var zone: Zone
var zone_position := Vector2.ZERO setget set_zone_position, get_zone_position

func bump() -> void:
    pass
    
func set_zone_position(value: Vector2) -> void:
    zone_position = value
    position = value * 16

func get_zone_position() -> Vector2:
    return zone_position
