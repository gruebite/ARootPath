extends Resource
class_name PlantArchetype

enum Kind {
    TREE,
    BUSH,
    FLOWER,
    FUNGUS,
    MOSS,    
}

export var identifier := "test_plant"
export(Kind) var kind: int = 0
# How often watering is needed, in runs.
export var watering_frequency := 3
# How many waterings in a row before going up a level.  Missing one resets and
# decreases a level.
export var waterings_per_level := 2
# Starting water level.
export var starting_water_level := 1
export var water_level_charges := [
    0, 1, 3, 6, 10,
]
