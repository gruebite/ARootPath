extends Node
class_name Tile

enum {
    EMPTY = -1,
    WALL,
    GROUND,
    WATER,
    # Object tiles.
    GRAVEL,
    GRASS,
    LILLY,
    SHIMMER,
    # Air
    FAIRY0,
}

static func walkable(t: int) -> bool:
    return t > 0 and t != -1
