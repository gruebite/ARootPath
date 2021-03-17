# Serializable game state, plus some extra global game state for UI.
extends Node

signal water_changed(to)
signal spell_charge_changed(kind, to)
signal spell_chained(amount)
signal spell_chain_stopped()

const ISLAND_WIDTH := 32
const ISLAND_HEIGHT := 32
const STARTING_WATER := 20
const MAX_WATER := 999
const MAX_CHAINS := 11

# How many dives.
var dive_count: int

# How much water we have.
var water: int

# List of plants based on location.  Updated everytime we return from the cavern.
var plant_state: Dictionary

# Island tile data.
var island_tiles: Dictionary

# Location of the petrified tree.
var petrified_tree_location: Vector2

# Refreshed when we return from the cavern.
var spell_charges: Array

# Reset when moving, set when casting a spell.
var chain_count := 0

# How many times the petrified tree has been invested.
var petrified_water := 0
var watered_petrified_tree := true

var island_walker: Walker

# Flavor variables for friendly slime.
var friendly_slime_state := {}
var saw_demon := false
var death_count := 0
var found_fairy_roots := false
var cavern_levels_reached := [false, false, false]

func _ready() -> void:
    pass

func modify_water(by: int) -> void:
    set_water(water + by)

func set_water(to: int) -> void:
    var new := int(clamp(to, 0, MAX_WATER))
    if new != water:
        water = new
        emit_signal("water_changed", water)

func set_spell_charges(kind: int, to: int) -> void:
    spell_charges[kind] = to
    emit_signal("spell_charge_changed", kind, to)

func inc_spell_charges(kind: int) -> void:
    set_spell_charges(kind, spell_charges[kind] + 1)

func use_spell_charge(kind: int) -> void:
    assert(spell_charges[kind] >= 0)
    set_spell_charges(kind, spell_charges[kind] - 1)

func can_cast_spell(kind: int) -> bool:
    if chain_count >= MAX_CHAINS or chain_count > water:
        return false
    return spell_charges[kind] != 0

func chain_spell() -> void:
    chain_count += 1
    emit_signal("spell_chained", chain_count)

func stop_spell_chain() -> void:
    chain_count = 0
    emit_signal("spell_chain_stopped")

func new_game() -> void:
    dive_count = 0
    set_water(STARTING_WATER)
    plant_state = {}
    island_tiles = {}
    spell_charges = [0, 0, 0, 0, 0]
    generate_island()

func generate_island() -> void:
    island_walker = Walker.new(Global.rng)

    island_walker.start(ISLAND_WIDTH, ISLAND_HEIGHT)
    island_walker.goto(ISLAND_WIDTH / 2, ISLAND_HEIGHT / 2)
    island_walker.mark(Tile.GROUND)
    island_walker.commit()
    while island_walker.percent_opened() < 0.6:
        island_walker.remember()
        island_walker.goto_random_closed()
        while not island_walker.on_opened():
            island_walker.step_weighted_last(0.55)
            island_walker.mark_plus(Tile.GROUND)
        island_walker.commit()
        island_walker.forget()
    island_walker.goto(ISLAND_WIDTH / 2, ISLAND_HEIGHT / 2)
    island_walker.mark_circle(2, Tile.WATER)
    for i in 40:
        island_walker.step_random()
        island_walker.mark_circle(2, Tile.WATER)
    island_walker.goto(ISLAND_WIDTH / 2, ISLAND_HEIGHT / 2)
    island_walker.mark_circle(6, Tile.WATER)
    island_walker.mark_circle(2, Tile.GROUND)
    island_walker.commit()

    # Save island state.
    island_tiles.clear()
    for y in ISLAND_HEIGHT:
        for x in ISLAND_WIDTH:
            var c = island_walker.grid[Vector2(x, y)]
            island_tiles[Vector2(x, y)] = c

    var island_rect := Rect2(Vector2.ZERO, Vector2(ISLAND_WIDTH, ISLAND_HEIGHT))
    while true:
        var x = Global.rng.randi_range(0, ISLAND_WIDTH - 1)
        var y = Global.rng.randi_range(0, ISLAND_HEIGHT - 1)
        var pos := Vector2(x, y)
        if island_tiles[pos] == Tile.GROUND:
            var below := pos + Vector2.DOWN
            if island_rect.has_point(below) and island_tiles[below] == Tile.GROUND:
                petrified_tree_location = pos
                break

func update_island() -> void:
    for i in Plant.COUNT:
        set_spell_charges(i, 0)

    var surviving := {}
    for pos in plant_state:
        var state: Dictionary = plant_state[pos]

        var res: PlantResource = Plant.KIND_RESOURCES[state["kind"]]
        state["age"] += 1
        var drought := Plant.state_drought_level(state)
        if drought >= res.watering_frequency:
            pass
        else:
            surviving[pos] = state
            set_spell_charges(state["kind"], spell_charges[state["kind"]] + Plant.state_charges(state))

    plant_state = surviving

# Flavor functions.

func has_spell_charges() -> bool:
    for charge in spell_charges:
        if charge > 0: return true
    return false
    
func total_spell_charges() -> int:
    var total := 0
    for pos in plant_state:
        total += Plant.state_water_needed(plant_state[pos])
    return total
    
func a_plant_needs_water() -> bool:
    for pos in plant_state:
        if Plant.state_water_needed(plant_state[pos]) > 0:
            return true
    return false
