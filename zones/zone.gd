extends Node2D
class_name Zone

const PLAYER = preload("res://player/player.tscn")

onready var entities = $entities

var player: Player

var entity_lookup := {}

func _ready() -> void:
    player = PLAYER.instance()
    add_entity(player)

func add_entity(ent: Entity) -> void:
    entities.add_child(ent)
    entity_lookup[ent.zone_position] = ent
    ent.position = ent.zone_position * 16

func remove_entity(ent: Entity) -> void:
    entities.remove_child(ent)
    entity_lookup.erase(ent.zone_position)

func get_entity_at(zpos: Vector2) -> Entity:
    return entity_lookup.get(zpos)

func move_entity(ent: Entity, to: Vector2) -> void:
    entity_lookup.erase(ent.zone_position)
    ent.zone_position = to
    ent.position = to * 16
    entity_lookup[to] = ent

func unwalkable(_pos: Vector2) -> bool:
    return false
