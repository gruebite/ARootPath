extends Resource
class_name ShapeCast

enum Kind {
    POINT,
    LINE,
    SQUARE,
    CIRCLE,
    CONE,
    WALL,
}

enum Direction {
    NONE,
    NORTH,
    EAST,
    SOUTH,
    WEST,    
}

export(Kind) var kind := Kind.POINT
export var size := 1

func cast(origin: Vector2, dir: int=Direction.NONE) -> Array:
    match kind:
        Kind.POINT: return [origin + __dir_to_vector(dir)]
        Kind.LINE:
            var arr := []
            var dirv := __dir_to_vector(dir)
            var iter := origin
            for i in size:
                iter += dirv
                arr.append(iter)
            return arr
        Kind.SQUARE:
            var arr := []
            var dirv := __dir_to_vector(dir)
            var center := origin + (dirv * size)
            for y in size * 2:
                for x in size * 2:
                    var dy: int = y - size
                    var dx: int = x - size
                    arr.append(center + Vector2(dx, dy))
            return arr
        Kind.CIRCLE:
            var arr := []
            var dirv := __dir_to_vector(dir)
            var center := origin + (dirv * size)
            for y in size * 2:
                for x in size * 2:
                    var dy: int = y - size
                    var dx: int = x - size
                    var v := Vector2(dx, dy)
                    if v.length_squared() <= size * size:
                        arr.append(center + v)
            return arr
        Kind.CONE: return []
        Kind.WALL: return []
    assert(false)
    return []

func __dir_to_vector(dir: int) -> Vector2:
    match dir:
        Direction.NORTH: return Vector2.UP
        Direction.EAST: return Vector2.RIGHT
        Direction.SOUTH: return Vector2.DOWN
        Direction.WEST: return Vector2.LEFT
    return Vector2.ZERO
