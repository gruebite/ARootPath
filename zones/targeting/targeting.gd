extends TileMap
class_name Targeting

enum Kind {
    NONE = -1,
    DAMAGE = 1,
    NO = 1,
    MOVEMENT = 2,
    YES = 2,
    STATUS = 3,
}

func add_point(point: Vector2, kind: int) -> void:
    set_cellv(point, kind)

func add_points(points: Array, kind: int) -> void:
    for pos in points:
        set_cellv(pos, kind)
