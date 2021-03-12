extends Resource
class_name ShapeCast

enum Kind {
    POINT,
    LINE,
    SQUARE,
    CIRCLE,
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
            var iter := origin
            for i in size:
                iter += dirv
                arr.append(iter)
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
                    if v.length_squared() < size * size:
                        arr.append(center + v)
            return arr
        Kind.CONE:
            var arr := []
            var dirv := Direction.delta(direction)
            for y in size * 2:
                for x in size * 2:
                    var dy: int = y - size
                    var dx: int = x - size
                    var v := Vector2(dx, dy)
                    if v.length_squared() <= size * size and abs(v.angle_to(dirv)) <= deg2rad(60):
                        arr.append(origin + v)
            return arr
    assert(false)
    return []

