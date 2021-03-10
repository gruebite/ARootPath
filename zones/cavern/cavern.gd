extends Zone
class_name Cavern

enum {
    TILE_WALL,
    TILE_GROUND,
}

const FOV_RADIUS := 10

const LEVEL_SIZES := [
    100, 141, 173
]

const LEVEL_ROOTS := [
    8, 5, 3,
]

const LAST_LEVEL := 2

const CAST_ACTION := preload("res://zones/cavern/action/cast_action.tscn")

const HOLE := preload("res://zones/cavern/hole/hole.tscn")
const ROOTS := preload("res://zones/cavern/roots/roots.tscn")

onready var fog = $fog
onready var slime_brain = $slime_brain

var fov := ShadowCast.new(funcref(self, "unwalkable"), funcref(self, "reveal"))
var unfov := ShadowCast.new(funcref(self, "unwalkable"), funcref(self, "unreveal"))

var spell_counts: Dictionary
var level := 0

var old_player_position: Vector2

func _ready() -> void:
    player.connect("took_turn", self, "_player_took_turn")
    slime_brain.zone = self
    slime_brain.level = level
    carve()
    
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        var action = CAST_ACTION.instance()
        game.main.action_layer.add_child(action)

func _player_took_turn() -> void:
    get_tree().call_group("turn_taker", "take_turn")
    # Have to recompute.
    unfov.compute(old_player_position, FOV_RADIUS)
    old_player_position = player.zone_position
    # TODO: Fix this.
    call_deferred("_update_fov")

func _update_fov() -> void:
    fov.compute(player.zone_position, FOV_RADIUS)

func unwalkable(zpos: Vector2) -> bool:
    return tiles.get_cell_autotile_coord(zpos.x, zpos.y) != Vector2(1, 0)

func carve() -> void:
    var size: int = LEVEL_SIZES[level]

    var walker := Walker.new(game.rng)
    walker.start(size, size)
    walker.goto(size / 2, size / 2)
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

    for x in size:
        for y in size:
            fog.set_cell(x, y, 0)
            var c: int = walker.grid[Vector2(x, y)]
            match c:
                TILE_GROUND:
                    tiles.set_cell(x, y, 0, false, false, false, Vector2(1, 0))
    
    if level < LAST_LEVEL:
        var holes_to_add := 1
        while holes_to_add > 0:
            var zpos := walker.opened_tiles.random(game.rng)
            # Must be far from entrance.
            if get_entity(zpos) or (zpos - Vector2(size / 2, size / 2)).length() < size / 4:
                continue
            add_entity_at(HOLE.instance(), zpos)
            holes_to_add -= 1
    
    var roots_to_add: int = LEVEL_ROOTS[level]
    while roots_to_add > 0:
        var zpos := walker.opened_tiles.random(game.rng)
        if get_entity(zpos):
            continue
        add_entity_at(ROOTS.instance(), zpos)
        roots_to_add -= 1
    
    player.zone_position = Vector2(size / 2, size / 2)
    old_player_position = player.zone_position
    fov.compute(player.zone_position, FOV_RADIUS)
    
    slime_brain.spawn_leeches(walker)

func unreveal(zpos: Vector2) -> void:
    var ent = get_entity(zpos)
    # Only hide non-players.
    if ent and not ent is Player:
        ent.visible = false
    fog.set_cellv(zpos, 2)

func reveal(zpos: Vector2) -> void:
    var ent = get_entity(zpos)
    if ent:
        ent.visible = true
    fog.set_cellv(zpos, 1)
