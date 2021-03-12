extends Node2D
class_name Entity

signal died()

#var game: Game = null
var map_position := Vector2.ZERO setget set_map_position, get_map_position
    
func set_map_position(value: Vector2) -> void:
    map_position = value.floor()
    position = value * 16

func get_map_position() -> Vector2:
    return map_position

