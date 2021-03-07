extends Zone
class_name Cavern

enum {
    TILE_WALL,
    TILE_GROUND,
}

const LEVEL_SIZES := [
    100, 141, 173
]

onready var tiles = $tiles
onready var fog = $fog
onready var entities = $entities
onready var player = $player

var fov := ShadowCast.new(funcref(self, "unwalkable"), funcref(self, "reveal"))
var unfov := ShadowCast.new(funcref(self, "unwalkable"), funcref(self, "unreveal"))

var level := 0

var entity_lookup := {}

func _ready():
    player.connect("player_moved", self, "player_moved")
    carve()

func unwalkable(zpos: Vector2) -> bool:
    return tiles.get_cell_autotile_coord(zpos.x, zpos.y) != Vector2(1, 0)

func carve() -> void:
    var width: int = LEVEL_SIZES[level]
    var height: int = LEVEL_SIZES[level]

    var walker := Walker.new()
    walker.start(width, height)
    walker.goto(width / 2, height / 2)
    walker.mark_plus(TILE_GROUND)
    walker.commit()
    while walker.percent_opened() < 0.6:
        walker.goto_random_opened()
        walker.remember()
        walker.goto_random_closed()
        while not walker.on_opened():
            walker.step_weighted_last(0.7)
            walker.mark_plus(TILE_GROUND)
        walker.commit()
        walker.forget()

    for x in width:
        for y in height:
            fog.set_cell(x, y, 0)
            var c: int = walker.grid[Vector2(x, y)]
            match c:
                TILE_GROUND:
                    tiles.set_cell(x, y, 0, false, false, false, Vector2(1, 0))
    player.zone_position = Vector2(width / 2, height / 2)
    fov.compute(Vector2(width / 2, height / 2), 8)

func player_moved(from: Vector2, to: Vector2) -> void:
    unfov.compute(from, 8)
    fov.compute(to, 8)
    entity_lookup.erase(from)
    entity_lookup[to] = player

func unreveal(zpos: Vector2) -> void:
    fog.set_cellv(zpos, 2)

func reveal(zpos: Vector2) -> void:
    fog.set_cellv(zpos, 1)
