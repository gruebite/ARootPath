extends Node
class_name Util

static func r2(index: float) -> Vector2:
    var x = 0.7548776662466927 * index
    var y = 0.5698402909980532 * index
    return Vector2(x - floor(x), y - floor(y))

static func r2d(index: float, optimal: bool=false) -> float:
    if optimal:
        return 0.868 / sqrt(index)
    else:
        return 0.549 / sqrt(index)

static func r2c(d: float, optimal: bool=false) -> float:
    if optimal:
        return pow(0.868 / d, 2)
    else:
        return pow(0.549 / d, 2)
