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

const MAX_STAGE := 3

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
    var drought: int = state_drought_level(state)
    if drought >= 0:
        return quant
    return 0

static func state_inc_age(state: Dictionary) -> void:
    state["age"] += 1

static func state_stage(state: Dictionary) -> int:
    return int(min(MAX_STAGE, floor(state["age"] / KIND_RESOURCES[state["kind"]].stage_period)))

static func state_mature(state: Dictionary) -> bool:
    return state_stage(state) >= KIND_RESOURCES[state["kind"]].mature_stage

static func state_charges(state: Dictionary) -> int:
    if state_drought_level(state) >= KIND_RESOURCES[state["kind"]].watering_frequency:
        return 0
    if state_mature(state):
        return 2
    return 1

func _ready() -> void:
    assume_stage()

func assume_stage() -> void:
    if get_child_count() > 0:
        get_child(0).queue_free()
    var stage := min(MAX_STAGE, get_stage())
    add_child(KIND_STAGES[get_kind()][stage].instance())

func water() -> void:
    get_state()["last_watered"] = get_age()

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
