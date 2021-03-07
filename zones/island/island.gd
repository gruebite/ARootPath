extends Zone
class_name Island

enum {
    TILE_VOID,
    TILE_GROUND,
    TILE_WATER,    
}

const WIDTH := 42
const HEIGHT := 42

onready var tiles := $tiles
onready var entities := $entities
onready var player := $player

func _ready():
    load_island()

func get_entity(zpos: Vector2) -> Entity:
    return .get_entity(zpos)

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

    game_state.island_tiles.clear()
    
    for y in HEIGHT:
        for x in WIDTH:
            var c = walker.grid[Vector2(x, y)]
            game_state.island_tiles[Vector2(x, y)] = c

func load_island() -> void:
    tiles.clear()
    for y in HEIGHT:
        for x in WIDTH:
            var c = game_state.island_tiles[Vector2(x, y)]
            match c:
                TILE_GROUND:
                    tiles.set_cell(x, y, 0, false, false, false, Vector2(1, 0))
                TILE_WATER:
                    tiles.set_cell(x, y, 0, false, false, false, Vector2(2, 0))

    player.zone_position = Vector2(WIDTH / 2, HEIGHT / 2)
