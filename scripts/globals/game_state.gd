extends Node
class_name GameState

const STARTING_MANA_CAPACITY := 6

# Capacity.  Used for growing plants on island, and chaining spells in cavern.
var mana_capacity: int

# List of plants based on location.  Updated everytime we return from the cavern.
var plant_state: Dictionary

# Island tile data.
var island_tiles: Dictionary

# Location of the petrified tree.
var petrified_tree_location: Vector2

func _ready() -> void:
    reset()

func reset() -> void:
    mana_capacity = STARTING_MANA_CAPACITY
    plant_state = {}
    island_tiles = {}
