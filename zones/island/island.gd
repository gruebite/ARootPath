extends Zone
class_name Island

enum {
    TILE_VOID,
    TILE_GROUND,
    TILE_WATER,    
}

const WIDTH := 42
const HEIGHT := 42

const GROW_ACTION := preload("res://zones/island/action/grow_action.tscn")
const PETRIFIED_TREE := preload("res://zones/island/petrified_tree/petrified_tree.tscn")
const SPRING := preload("res://zones/island/spring/spring.tscn")
const PLANT := preload("res://zones/island/plant/plant.tscn")

var spring: Entity
var petrified_tree: Entity

# Set if we're coming from the cavern.
var returning_from_cavern := false

func _ready() -> void:
    load_island()
    if returning_from_cavern:
        returned_from_cavern()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        var action = GROW_ACTION.instance()
        game.main.action_layer.add_child(action)

func unwalkable(zpos: Vector2) -> bool:
    return tiles.get_cell_autotile_coord(zpos.x, zpos.y) == Vector2(0, 0)
    
func generate_island() -> void:
    var walker := Walker.new(game.rng)

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
    while true:
        var x = game.rng.randi_range(0, WIDTH - 1)
        var y = game.rng.randi_range(0, HEIGHT - 1)
        if game_state.island_tiles[Vector2(x, y)] == TILE_GROUND:
            game_state.petrified_tree_location = Vector2(x, y)
            break

func load_island() -> void:
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
    
    player.zone_position = Vector2(WIDTH / 2, HEIGHT / 2 + 1)
    spring = SPRING.instance()
    add_entity_at(spring, Vector2(WIDTH / 2, HEIGHT / 2))
    petrified_tree = PETRIFIED_TREE.instance()
    add_entity_at(petrified_tree, game_state.petrified_tree_location)
    
    for zpos in game_state.plant_state:
        var inst: Plant = PLANT.instance()
        add_entity_at(inst, zpos)

func can_grow() -> bool:
    return len(game_state.plant_state) < game_state.water

func can_grow_at(zpos: Vector2) -> bool:
    return can_grow() and game_state.plant_state.get(zpos) == null and zpos != spring.zone_position and zpos != petrified_tree.zone_position

func grow_plant(id: String, zpos: Vector2) -> void:
    assert(can_grow_at(zpos))
    var plant: Plant = PLANT.instance()
    add_entity_at(plant, zpos)
    # This function fills in plant_state.
    plant.grow_into(id)

func count_spells() -> Dictionary:
    # The petrified tree provides 1 of each spell.
    var counts := {
        PlantArchetype.Kind.TREE: 1,
        PlantArchetype.Kind.BUSH: 1,
        PlantArchetype.Kind.FLOWER: 1,
        PlantArchetype.Kind.FUNGUS: 1,
        PlantArchetype.Kind.MOSS: 1,
    }
    for n in get_tree().get_nodes_in_group("plant"):
        var plant: Plant = n
        counts[plant.get_kind()] = counts.get(plant.get_kind(), 0) + plant.get_current_stage_charges()
    return counts

func leaving_for_cavern() -> void:
    # Update plant state.
    get_tree().call_group("plant", "_leaving_for_cavern")

func returned_from_cavern() -> void:
    # Update plant state.
    get_tree().call_group("plant", "_returned_from_cavern")
