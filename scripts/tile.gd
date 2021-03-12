extends Node
class_name Tile

enum {
    EMPTY = -1,
    WALL,
    GROUND,
    WATER,
    GRAVEL,
}

static func walkable(t: int) -> bool:
    return t > 0 and t != -1
