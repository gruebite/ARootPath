# Serializable game state, plus some extra global game state for UI.
extends Node

signal water_changed(to)
signal spell_charge_changed(kind, to)
signal spell_chained(amount)
signal spell_chain_stopped()

const ISLAND_WIDTH := 42
const ISLAND_HEIGHT := 42
const STARTING_WATER := 5
const MAX_WATER := 99
const MAX_CHAINS := 10

# How many delves.
var delve_count: int

# How much water we have.
var water: int

# List of plants based on location.  Updated everytime we return from the cavern.
var plant_state: Dictionary

# Island tile data.
var island_tiles: Dictionary

# Location of the petrified tree.
var petrified_tree_location: Vector2
# Player spawn location, near the petrified tree.
var return_location: Vector2

# Refreshed when we return from the cavern.
var spell_charges: Array

# Reset when moving, set when casting a spell.
var chain_count := 0

func _ready() -> void:
    pass
    
func modify_water(by: int) -> void:
    set_water(water + by)
    
func set_water(to: int) -> void:
    var new := int(clamp(to, 0, MAX_WATER))
    if new != water:
        water = new
        emit_signal("water_changed", water)

func set_spell_charge(kind: int, to: int) -> void:
    spell_charges[kind] = to
    emit_signal("spell_charge_changed", kind, to)
    
func use_spell_charge(kind: int) -> void:
    assert(spell_charges[kind] >= 0)
    set_spell_charge(kind, spell_charges[kind] - 1)

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
    delve_count = 0
    set_water(STARTING_WATER)
    plant_state = {}
    island_tiles = {}
    spell_charges = [0, 0, 0, 0, 0]
    generate_island()

func generate_island() -> void:
    var walker := Walker.new(Global.rng)

    walker.start(ISLAND_WIDTH, ISLAND_HEIGHT)
    walker.goto(ISLAND_WIDTH / 2, ISLAND_HEIGHT / 2)
    walker.mark_circle(6, Tile.GROUND)
    walker.commit()
    while walker.percent_opened() < 0.6:
        walker.remember()
        walker.goto_random_closed()
        while not walker.on_opened():
            walker.step_weighted_last(0.55)
            walker.mark_plus(Tile.GROUND)
        walker.commit()
        walker.forget()
    walker.goto(ISLAND_WIDTH / 2, ISLAND_HEIGHT / 2)
    for i in 40:
        walker.step_random()
        walker.mark_circle(2, Tile.WATER)
    walker.commit()

    # Save island state.
    island_tiles.clear()
    for y in ISLAND_HEIGHT:
        for x in ISLAND_WIDTH:
            var c = walker.grid[Vector2(x, y)]
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
                return_location = below
                break

func update_island() -> void:
    for i in Plant.COUNT:
        set_spell_charge(i, 0)
    set_spell_charge(Plant.Kind.FLOWER, 1)
    
    var surviving := {}
    for pos in plant_state:
        var state: Dictionary = plant_state[pos]
        
        var res: PlantResource = Plant.KIND_RESOURCES[state["kind"]]
        state["age"] += 1
        var drought := Plant.state_drought_level(state)
        if drought >= res.drought_limit:
            pass
        else:
            surviving[pos] = state
            set_spell_charge(state["kind"], spell_charges[state["kind"]] + Plant.state_charges(state))
    
    plant_state = surviving
            
