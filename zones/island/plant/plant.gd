extends Entity
class_name Plant

signal died_from_dought()
signal died_from_age()

const OAK := "oak"
const ARCHETYPES := {
    OAK: preload("res://zones/island/plant/archetypes/oak.tres"),
}

var needs_watering: bool = false

func _returned_from_cavern() -> void:
    get_state()["age"] += 1
    if get_age() >= get_lifespan():
        emit_signal("kill_me")
        emit_signal("died_from_age")
    var runs_since_watered := get_age() - get_last_watered()
    var drought_time := runs_since_watered - get_watering_frequency()
    if drought_time >= 0:
        needs_watering = true
        if drought_time > get_drought_limit():
            emit_signal("kill_me")
            emit_signal("died_from_drought")

func _leaving_for_cavern() -> void:
    if needs_watering:
        get_state()["waterings"] = 0

func bump() -> void:
    game.main.show_message(["Growing strong."])

func grow_into(arch_id: String) -> void:
    game_state.plant_state[zone_position] = {
        "id": arch_id,
        # Age in runs.
        "age": 0,
        # Age when last watered.
        "last_watered": 0,
    }
    texture = get_archetype().texture

func water() -> void:
    assert(needs_watering)
    needs_watering = false
    get_state()["last_watered"] = get_age()

func get_state() -> Dictionary:
    return game_state.plant_state[zone_position]

func get_age() -> int:
    return get_state()["age"]

func get_last_watered() -> int:
    return get_state()["last_watered"]

func get_current_stage() -> int:
    var i := 0
    for limit in get_stage_ages():
        if get_age() < limit:
            break
        i += 1
    return i

func get_current_stage_charges() -> int:
    return get_stage_charges()[get_current_stage()]

func get_archetype_id() -> String:
    return get_state()["id"]

func get_archetype() -> PlantArchetype:
    return ARCHETYPES[get_archetype_id()] as PlantArchetype

func get_kind() -> int:
    return get_archetype().kind

func get_watering_frequency() -> int:
    return get_archetype().watering_frequency

func get_watering_quantity() -> int:
    return get_archetype().watering_quantity

func get_drought_limit() -> int:
    return get_archetype().drought_limit

func get_lifespan() -> int:
    return get_archetype().drought_limit

func get_stage_ages() -> Array:
    return get_archetype().stage_ages

func get_stage_charges() -> Array:
    return get_archetype().stage_ages
