extends NinePatchRect

const X_PAD := 9
const Y_PAD := 8
const HEIGHT := 15

var max_health := 27
var health: float = max_health

func _ready():
    hide()

func _draw():
    var width = get_rect().size.x - (X_PAD*2)
    draw_rect(Rect2(X_PAD, Y_PAD, floor(width * (health / max_health)), HEIGHT), Color.green, true)
