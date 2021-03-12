extends Entity
class_name Plant

enum Kind {
    TREE,
    BUSH,
    FLOWER,
    FUNGUS,
    MOSS,
}

const COUNT := 5

const MAX_STAGE := 4

const KIND_RESOURCES = [
    preload("res://entities/plant/resources/tree.tres"),
    preload("res://entities/plant/resources/bush.tres"),
    preload("res://entities/plant/resources/flower.tres"),
    preload("res://entities/plant/resources/fungus.tres"),
    preload("res://entities/plant/resources/moss.tres"),
]

const KIND_STAGES := [
    [preload("res://entities/plant/stages/tree/tree0.tscn"), preload("res://entities/plant/stages/tree/tree1.tscn"),
     preload("res://entities/plant/stages/tree/tree2.tscn"), preload("res://entities/plant/stages/tree/tree3.tscn")],

    [preload("res://entities/plant/stages/bush/bush0.tscn"), preload("res://entities/plant/stages/bush/bush1.tscn"),
     preload("res://entities/plant/stages/bush/bush2.tscn"), preload("res://entities/plant/stages/bush/bush3.tscn")],

    [preload("res://entities/plant/stages/flower/flower0.tscn"), preload("res://entities/plant/stages/flower/flower1.tscn"),
     preload("res://entities/plant/stages/flower/flower2.tscn"), preload("res://entities/plant/stages/flower/flower3.tscn")],

    [preload("res://entities/plant/stages/fungus/fungus0.tscn"), preload("res://entities/plant/stages/fungus/fungus1.tscn"),
     preload("res://entities/plant/stages/fungus/fungus2.tscn"), preload("res://entities/plant/stages/fungus/fungus3.tscn")],

    [preload("res://entities/plant/stages/moss/moss0.tscn"), preload("res://entities/plant/stages/moss/moss1.tscn"),
     preload("res://entities/plant/stages/moss/moss2.tscn"), preload("res://entities/plant/stages/moss/moss3.tscn")],
]

# < 0 means no water needed, 0 means water needs, 1 means drought
static func state_drought_level(state: Dictionary) -> int:
    var diff: int = state["age"] - state["last_watered"]
    return int(diff - KIND_RESOURCES[state["kind"]].watering_frequency)

static func state_water_needed(state: Dictionary) -> int:
    var quant: int = KIND_RESOURCES[state["kind"]].watering_quantity
    return int(max(0, state_drought_level(state) + 1) * quant)

static func state_inc_age(state: Dictionary) -> void:
    state["age"] += 1

static func state_stage(state: Dictionary) -> int:
    return int(min(MAX_STAGE, floor(state["age"] / KIND_RESOURCES[state["kind"]].growth_period)))

static func state_charges(state: Dictionary) -> int:
    return KIND_RESOURCES[state["kind"]].spell_charges * state_stage(state)

func _ready() -> void:
    var stage := min(MAX_STAGE, floor(get_age() / get_resource().growth_period))
    add_child(KIND_STAGES[get_kind()][stage].instance())

func get_state() -> Dictionary:
    var state = GameState.plant_state[map_position]
    return state

func get_kind() -> int:
    return get_state()["kind"]

func get_age() -> int:
    return get_state()["age"]

func get_last_watered() -> int:
    return get_state()["last_watered"]

func get_resource() -> PlantResource:
    return KIND_RESOURCES[get_kind()]

func get_drought_level() -> int:
    return state_drought_level(get_state())

func get_water_needed() -> int:
    return state_water_needed(get_state())

func needs_water() -> bool:
    return get_water_needed() > 0

func get_stage() -> int:
    return state_stage(get_state())

func get_charges() -> int:
    return state_charges(get_state())
