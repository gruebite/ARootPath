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
    SLIMY_WATER,
    PURIFIED_WATER,
    # Animated tiles.
    LILY,
    SHIMMER,
    # Air
    FAIRY0,
    FIARY1,
    FAIRY2,
}

static func walkable(t: int) -> bool:
    return t > 0 and t != -1
