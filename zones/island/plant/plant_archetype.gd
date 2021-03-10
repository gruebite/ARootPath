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

# Kind of plant.  Determines which spell they give charges for.
export(Kind) var kind: int = Kind.TREE

export(Texture) var texture

# How much water is needed to grow this plant.
export var grow_cost := 5
# How often watering is needed, in runs.
export var watering_frequency := 3
# How much water is needed.
export var watering_quantity := 2
# How many runs this plant can go without water before dying.  An unwatered
# plant gives 0 charges.
export var drought_limit := 2
# How long the plant lives before dying.
export var lifespan := 40
# Age (in runs) limits for each stage.
export var stage_ages := [
    3,
    5,
    8,
]
# Stages of age, the first stage is a sprout, but after that it gives charges.
export var stage_charges := [
    0,
    3,
    5,
    8,
]
