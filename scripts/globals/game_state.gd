extends Node
class_name GameState

const STARTING_MANA_CAPACITY := 6

var mana_capacity := STARTING_MANA_CAPACITY
var allocated := 0
var mana := mana_capacity

# List of plants based on location.
var plants := {}

# Island tile data.
var island_tiles := {}

func reset() -> void:
    mana_capacity = STARTING_MANA_CAPACITY
    allocated = 0
    mana = mana_capacity
    plants = {}
    island_tiles = {}
