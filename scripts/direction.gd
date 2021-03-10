extends Reference
class_name Direction

enum {
    NORTH,
    NORTHEAST,
    EAST,
    SOUTHEAST,
    SOUTH,
    SOUTHWEST,
    WEST,
    NORTHWEST, 
}

const COUNT := 8

static func delta(dir: int) -> Vector2:
    match dir:
        NORTH: return Vector2(0, -1)
        NORTHEAST: return Vector2(1, -1)
        EAST: return Vector2(1, 0)
        SOUTHEAST: return Vector2(1, 1)
        SOUTH: return Vector2(0, 1)
        SOUTHWEST: return Vector2(-1, 1)
        WEST: return Vector2(-1, 0)
        NORTHWEST: return Vector2(-1, -1)
    return Vector2.ZERO


static func is_cardinal(dir: int) -> bool:
    match dir:
        NORTH: return true
        EAST: return true
        SOUTH: return true
        WEST: return true
    return false
