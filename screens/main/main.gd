extends Node2D
class_name Main

const ISLAND = preload("res://zones/island/island.tscn")
const CAVERN = preload("res://zones/cavern/cavern.tscn")

onready var zone: Node2D = $zone
onready var hud_layer: CanvasLayer = $hud_layer
onready var text_layer: CanvasLayer = $text_layer
onready var action_layer: CanvasLayer = $action_layer

var current_zone: Zone = null

func _ready():
    game.main = self
    game_state.reset()
    
    var island: Island = ISLAND.instance()
    island.generate_island()
    current_zone = island
    zone.add_child(island)

func warp_island() -> void:
    var island: Island = ISLAND.instance()
    
    island.returning_from_cavern = true
    
    current_zone.queue_free()
    current_zone = island
    zone.add_child(island)

func warp_cavern(level: int=0) -> void:
    var cavern: Cavern = CAVERN.instance()
    cavern.level = level
    
    if current_zone is Island:
        var island: Island = current_zone
        island.leaving_for_cavern()
        cavern.spell_counts = island.count_spells()
    else:
        var old_cavern: Cavern = current_zone
        cavern.spell_counts = old_cavern.spell_counts
    
    current_zone.queue_free()
    current_zone = cavern
    zone.add_child(cavern)
