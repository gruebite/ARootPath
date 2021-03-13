extends SlimeBase

var growing := true

func _ready() -> void:
    hide()

func grow_up() -> void:
    assert(growing)
    if frozen: return
    growing = false
    $Growing.hide()
    $Grown.show()
