extends TileMap
class_name FOG

enum {
    UNREVEALED,
    REVEALED,
    SEEN,    
}

const RADIUS := 7

export var space_path := NodePath()

var old = null

onready var space: Space = get_node(space_path)
onready var fov := ShadowCast.new(funcref(get_parent(), "unwalkable"), funcref(self, "reveal"))
onready var unfov := ShadowCast.new(funcref(get_parent(), "unwalkable"), funcref(self, "unreveal"))

func reset() -> void:
    clear()
    old = null

func unreveal_area(width: int, height: int) -> void:
    for x in width:
        for y in height:
            set_cell(x, y, UNREVEALED)

func is_revealed(mpos: Vector2) -> bool:
    return not visible or get_cellv(mpos) == REVEALED

func recompute(at: Vector2) -> void:
    if old:
        unfov.compute(old, RADIUS)
    old = at
    fov.compute(at, RADIUS)

func unreveal(mpos: Vector2) -> void:
    set_cellv(mpos, SEEN)
    var ent = space.entities.get_entity(mpos)
    if ent:
        ent.hide()

func reveal(mpos: Vector2) -> void:
    set_cellv(mpos, REVEALED)
    var ent = space.entities.get_entity(mpos)
    if ent:
        ent.show()

func random_revealed() -> Vector2:
    var arr := get_used_cells_by_id(REVEALED)
    if len(arr) == 0: return Vector2.ZERO
    return arr[Global.rng.randi_range(0, len(arr) - 1)]
