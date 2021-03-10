extends Node2D
class_name Zone

onready var tiles = $tiles
onready var objects = $objects
onready var entities = $entities
onready var player = $player
onready var targeting = $targeting

var entity_lookup := {}

func _ready() -> void:
    player.zone = self

func add_entity_at(ent, zpos: Vector2) -> void:
    assert(not entity_lookup.has(zpos))
    ent.zone = self
    ent.zone_position = zpos
    entities.add_child(ent)
    entity_lookup[ent.zone_position] = ent

func remove_entity(ent) -> void:
    assert(entity_lookup.has(ent.zone_position))
    entities.remove_child(ent)
    entity_lookup.erase(ent.zone_position)

func get_entity(zpos: Vector2) -> Node2D:
    return entity_lookup.get(zpos)

func move_entity(ent, to: Vector2) -> void:
    assert(not entity_lookup.has(to))
    entity_lookup.erase(ent.zone_position)
    ent.zone_position = to
    entity_lookup[to] = ent

func kill_entity(ent) -> void:
    remove_entity(ent)
    ent.queue_free()

func unwalkable(_pos: Vector2) -> bool:
    return false
