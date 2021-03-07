
# Taken from http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html#shadowcode
extends Reference
class_name ShadowCast

const __TRANSFORMS = [
    {"xx": 1, "xy": 0, "yx": 0, "yy": 1},
    {"xx": 1, "xy": 0, "yx": 0, "yy": -1},
    {"xx": -1, "xy": 0, "yx": 0, "yy": 1},
    {"xx": -1, "xy": 0, "yx": 0, "yy": -1},
    {"xx": 0, "xy": 1, "yx": 1, "yy": 0},
    {"xx": 0, "xy": 1, "yx": -1, "yy": 0},
    {"xx": 0, "xy": -1, "yx": 1, "yy": 0},
    {"xx": 0, "xy": -1, "yx": -1, "yy": 0},
]

var __is_opaque = null
var __reveal = null

func _init(opaque, reveal):
    __is_opaque = opaque
    __reveal = reveal

func compute(origin: Vector2, radius: int):
    __reveal.call_func(origin)
    for i in range(8):
        __scan(__TRANSFORMS[i], origin, radius, 1, 1, 1, 0, 1)


func __scan(trans: Dictionary, origin: Vector2, radius: int, xx: int, top_y: int, top_x: int, bottom_y: int, bottom_x: int):
    for x in range(xx, radius + 1):
        var new_top_y: int = 0
        if top_x == 1:
            new_top_y = x
        else:
            new_top_y = ((x * 2 + 1) * top_y + top_x - 1) / (top_x * 2)
        var new_bottom_y: int = 0
        if bottom_y == 0:
            new_bottom_y = 0
        else:
            new_bottom_y = ((x * 2 - 1) * bottom_y + bottom_x) / (bottom_x * 2)
        
        var was_opaque := -1
        for y in range(new_top_y, new_bottom_y - 1, -1):
            var realx = origin.x + trans["xx"] * x + trans["xy"] * y
            var realy = origin.y + trans["yx"] * x + trans["yy"] * y
            var realv := Vector2(realx, realy)
            var in_range := radius < 0 || origin.distance_squared_to(realv) <= radius * radius
            if in_range && (y != new_top_y || top_y * x >= top_x * y) && (y != new_bottom_y || bottom_y * x <= bottom_x * y):
                __reveal.call_func(realv)
            
            var is_opaque: bool = !in_range || __is_opaque.call_func(realv)
            if x != radius:
                if is_opaque:
                    if was_opaque == 0:
                        var new_y := y * 2 + 1
                        var new_x := x * 2 - 1
                        if !in_range || y == new_bottom_y:
                            bottom_y = new_y
                            bottom_x = new_x
                            break
                        else:
                            __scan(trans, origin, radius, x + 1, top_y, top_x, new_y, new_x)
                    was_opaque = 1
                else:
                    if was_opaque > 0:
                        top_y = y * 2 + 1
                        top_x = x * 2 + 1
                    was_opaque = 0
        if was_opaque != 0:
            break

