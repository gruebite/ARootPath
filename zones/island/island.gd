extends Zone
class_name Island

enum {
    TILE_VOID,
    TILE_GROUND,
    TILE_WATER,    
}

const WIDTH := 42
const HEIGHT := 42

const SPRING := preload("res://zones/island/spring/spring.tscn")
const PLANT := preload("res://zones/island/plant/plant.tscn")

onready var tiles := $tiles

var spring: Entity

# Set if we're coming from the cavern.
var returning_from_cavern := false

func _ready():
    load_island()
    if returning_from_cavern:
        returned_from_cavern()

func unwalkable(zpos: Vector2) -> bool:
    return tiles.get_cell_autotile_coord(zpos.x, zpos.y) == Vector2(1, 0)
    
func generate_island() -> void:
    var walker := Walker.new()

    walker.start(WIDTH, HEIGHT)
    walker.goto(WIDTH / 2, HEIGHT / 2)
    walker.mark_circle(6, TILE_WATER)
    walker.commit()
    while walker.percent_opened() < 0.6:
        walker.remember()
        walker.goto_random_closed()
        while not walker.on_opened():
            walker.step_weighted_last(0.55)
            walker.mark_plus(TILE_GROUND)
        walker.commit()
        walker.forget()

    # Save island state.
    game_state.island_tiles.clear()
    for y in HEIGHT:
        for x in WIDTH:
            var c = walker.grid[Vector2(x, y)]
            game_state.island_tiles[Vector2(x, y)] = c

func load_island() -> void:
    spring = SPRING.instance()
    add_entity(spring)
    
    # Load island state.
    tiles.clear()
    for y in HEIGHT:
        for x in WIDTH:
            var c = game_state.island_tiles[Vector2(x, y)]
            match c:
                TILE_GROUND:
                    tiles.set_cell(x, y, 0, false, false, false, Vector2(1, 0))
                TILE_WATER:
                    tiles.set_cell(x, y, 0, false, false, false, Vector2(2, 0))

    move_entity(player, Vector2(WIDTH / 2, HEIGHT / 2 + 1))
    move_entity(spring, Vector2(WIDTH / 2, HEIGHT / 2))
    
    for zpos in game_state.plant_state:
        var inst: Plant = Plant.instance()
        inst.zone_position = zpos
        add_entity(inst)

func can_grow() -> bool:
    return len(game_state.plant_state) < game_state.mana_capacity

func can_grow_at(zpos: Vector2) -> bool:
    return can_grow() and game_state.plant_state.get(zpos) == null

func grow_plant(id: String, zpos: Vector2) -> void:
    assert(can_grow_at(zpos))
    var plant: Plant = PLANT.instance()
    plant.zone_position = zpos
    # This function fills in plant_state.
    plant.grow_into(id)

func count_spells() -> Dictionary:
    var counts := {}
    for n in get_tree().get_nodes_in_group("plant"):
        var plant: Plant = n
        counts[plant.kind_id] = counts.get(plant.kind_id, 0) + plant.get_water_level_charges()
    return counts

func leaving_for_cavern() -> void:
    # Update plant state.
    get_tree().call_group("plant", "_leaving_for_cavern")

func returned_from_cavern() -> void:
    # Update plant state.
    get_tree().call_group("plant", "_returned_from_cavern")
