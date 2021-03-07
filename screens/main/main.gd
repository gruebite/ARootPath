extends Node2D
class_name Main

const ISLAND = preload("res://zones/island/island.tscn")
const CAVERN = preload("res://zones/cavern/cavern.tscn")

onready var zone: Node2D = $zone

func _ready():
    game.main = self
    game_state.reset()
    
    var island: Island = ISLAND.instance()
    island.generate_island()
    zone.add_child(island)

func warp_island() -> void:
    zone.remove_child(zone.get_child(0))
    var island: Island = ISLAND.instance()
    island.load_island()
    zone.add_child(island)

func warp_cavern(level: int=0) -> void:
    zone.remove_child(zone.get_child(0))
    var cavern: Cavern = CAVERN.instance()
    cavern.level = level
    zone.add_child(cavern)
