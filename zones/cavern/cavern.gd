extends Zone
class_name Cavern

enum {
    TILE_WALL,
    TILE_GROUND,
}

const LEVEL_SIZES := [
    100, 141, 173
]

const CAST_ACTION := preload("res://zones/cavern/action/cast_action.tscn")

const SLIME := preload("res://zones/cavern/slime/slime.tscn")

onready var tiles = $tiles
onready var fog = $fog

var fov := ShadowCast.new(funcref(self, "unwalkable"), funcref(self, "reveal"))
var unfov := ShadowCast.new(funcref(self, "unwalkable"), funcref(self, "unreveal"))

var spell_counts: Dictionary
var level := 0

func _ready() -> void:
    carve()
    
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        var action = CAST_ACTION.instance()
        game.main.action_layer.add_child(action)

func move_entity(ent: Entity, to: Vector2) -> void:
    if ent.is_in_group("player"):
        unfov.compute(ent.zone_position, 8)
        fov.compute(to, 8)
    .move_entity(ent, to)

func unwalkable(zpos: Vector2) -> bool:
    return tiles.get_cell_autotile_coord(zpos.x, zpos.y) != Vector2(1, 0)

func carve() -> void:
    var width: int = LEVEL_SIZES[level]
    var height: int = LEVEL_SIZES[level]

    var walker := Walker.new(game.rng)
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
    
    move_entity(player, Vector2(width / 2, height / 2))

func unreveal(zpos: Vector2) -> void:
    fog.set_cellv(zpos, 2)

func reveal(zpos: Vector2) -> void:
    fog.set_cellv(zpos, 1)
