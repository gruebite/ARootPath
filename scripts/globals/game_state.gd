extends Node
class_name GameState

const STARTING_WATER := 20

# How much water we have.
var water: int

# List of plants based on location.  Updated everytime we return from the cavern.
var plant_state: Dictionary

# Island tile data.
var island_tiles: Dictionary

# Location of the petrified tree.
var petrified_tree_location: Vector2

func _ready() -> void:
    reset()

func reset() -> void:
    water = STARTING_WATER
    plant_state = {}
    island_tiles = {}
