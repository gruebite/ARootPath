extends TileMap
class_name FOG

enum {
    UNREVEALED,
    REVEALED,
    SEEN,    
}

const RADIUS := 7

onready var fov := ShadowCast.new(funcref(get_parent(), "unwalkable"), funcref(self, "reveal"))
onready var unfov := ShadowCast.new(funcref(get_parent(), "unwalkable"), funcref(self, "unreveal"))

func unreveal_area(width: int, height: int) -> void:
    for x in width:
        for y in height:
            set_cell(x, y, UNREVEALED)

func is_revealed(mpos: Vector2) -> bool:
    return not visible or get_cellv(mpos) == REVEALED

func recompute(old: Vector2, new: Vector2) -> void:
    unfov.compute(old, RADIUS)
    fov.compute(new, RADIUS)

func unreveal(mpos: Vector2) -> void:
    set_cellv(mpos, SEEN)

func reveal(mpos: Vector2) -> void:
    set_cellv(mpos, REVEALED)

func random_revealed() -> Vector2:
    var arr := get_used_cells_by_id(REVEALED)
    if len(arr) == 0: return Vector2.ZERO
    return arr[Global.rng.randi_range(0, len(arr) - 1)]
