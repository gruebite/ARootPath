extends Entity
class_name Plant

const CLEAVING_OAK := "cleaving_oak"
const KINDS := {
    CLEAVING_OAK: preload("res://zones/island/plant/kinds/cleaving_oak.tres"),
}

# Set to false when we need to be watered.
var needs_watering: bool = false

func _returned_from_cavern() -> void:
    get_state()["last_watered_count"] += 1
    needs_watering = get_last_watered_count() >= get_watering_frequency()

func _leaving_for_cavern() -> void:
    if needs_watering:
        get_state()["water_level"] = max(0, get_state()["water_level"] - 1)
        get_state()["waterings"] = 0

func grow_into(kind_id: String) -> void:
    game_state.plant_state[zone_position] = {
        "id": kind_id,
        # Water level.  Increased by consistent watering.
        "water_level": KINDS[kind_id].starting_water_level,
        # Number of waterings in a row.
        "waterings": 0,
        # Number of runs since last watered.
        "last_watered_count": 0,
    }

func water() -> void:
    assert(needs_watering)
    needs_watering = false
    get_state()["waterings"] = get_state()["waterings"] + 1
    if get_waterings() == get_waterings_per_level():
        get_state()["waterings"] = 0
        get_state()["water_level"] = max(get_max_water_level(), get_state()["water_level"] + 1)
    get_state()["last_watered_count"] = 0

func get_state() -> Dictionary:
    return game_state.plant_state[zone_position]

func get_kind_id() -> String:
    return get_state()["kind_id"]

func get_water_level() -> int:
    return get_state()["water_level"]
    
func get_waterings() -> int:
    return get_state()["waterings"]
    
func get_last_watered_count() -> int:
    return get_state()["last_watered_count"]

func get_kind() -> PlantKind:
    return KINDS[get_kind_id()] as PlantKind

func get_watering_frequency() -> int:
    return get_kind().watering_frequency

func get_waterings_per_level() -> int:
    return get_kind().waterings_per_level

func get_max_water_level() -> int:
    return len(get_kind().water_level_charges) - 1

func get_water_level_charges() -> int:
    return get_kind().water_level_charges[get_water_level()]
