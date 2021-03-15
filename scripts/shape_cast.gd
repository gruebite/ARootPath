extends Resource
class_name ShapeCast

enum Kind {
    POINT,
    LINE,
    SQUARE,
    CIRCLE,
    PLUS,
    CONE,
}

export(Kind) var kind := Kind.POINT
export var size := 1

var origin := Vector2.ZERO
var direction: int = -1

func _init(k: int=Kind.POINT, sz: int=1) -> void:
    kind = k
    size = sz

func cast() -> Array:
    match kind:
        Kind.POINT: return [origin + Direction.delta(direction)]
        Kind.LINE:
            var arr := []
            var dirv := Direction.delta(direction)
            var iter := origin + dirv
            for i in size:
                arr.append(iter)
                iter += dirv
            return arr
        Kind.SQUARE:
            var arr := []
            var dirv := Direction.delta(direction)
            var center := origin + (dirv * size)
            for y in size * 2:
                for x in size * 2:
                    var dy: int = y - size
                    var dx: int = x - size
                    arr.append(center + Vector2(dx, dy))
            return arr
        Kind.CIRCLE:
            var arr := []
            var dirv := Direction.delta(direction)
            var center := origin + (dirv * size)
            for y in size * 2:
                for x in size * 2:
                    var dy: int = y - size
                    var dx: int = x - size
                    var v := Vector2(dx, dy)
                    if kind == Kind.CIRCLE and v.length_squared() < size * size:
                        arr.append(center + v)
            return arr
        Kind.PLUS:
            var dirv := Direction.delta(direction)
            var center := origin + (dirv * size)
            var arr := [center]
            for d in range(0, Direction.COUNT, 2):
                arr.append(center + Direction.delta(d))
            return arr
        Kind.CONE:
            var arr := []
            var dirv := Direction.delta(direction)
            for y in size * 2:
                for x in size * 2:
                    var dy: int = y - size
                    var dx: int = x - size
                    var v := Vector2(dx, dy)
                    if v == Vector2.ZERO:
                        continue
                    if v.length_squared() < size * size and abs(v.angle_to(dirv)) <= deg2rad(60):
                        arr.append(origin + v)
            return arr
    assert(false)
    return []

