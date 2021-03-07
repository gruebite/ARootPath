extends Node2D
class_name Zone

func _ready() -> void:
    game.current_zone = self

func get_entity(_pos: Vector2) -> Entity:
    return null

func get_tile(_pos: Vector2) -> int:
    return -1
