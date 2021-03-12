extends Resource
class_name PlantResource

export var name := ""

export(String, MULTILINE) var description := ""

export(String, MULTILINE) var spell_description := ""

# How much water is needed to grow this plant.
export var grow_cost := 5

# How many runs before the plant matures.
export var growth_period := 5

# How many spell charges this grants once mature.
export var spell_charges := 3

# How often watering is needed, in runs.
export var watering_frequency := 3

# How much water is needed.
export var watering_quantity := 2

# How many runs this plant can go without water before dying.  An unwatered
# plant gives 0 charges.
export var drought_limit := 2
