extends Resource
class_name PlantResource

export var name := ""

export(String, MULTILINE) var description := ""

export(String, MULTILINE) var spell_description := ""

# How much water is needed to grow this plant.
export var grow_cost := 5

# How many runs before the plant matures.
export var stage_period := 5

# Stage of maturity.
export var mature_stage := 1

# How often watering is needed, in runs.
export var watering_frequency := 3

# How much water is needed.
export var watering_quantity := 2

# How many spaces it needs to grow.
export var space_needed := 0
