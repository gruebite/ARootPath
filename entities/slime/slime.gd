extends SlimeBase

var growing := true

func grow_up() -> void:
    assert(growing)
    if frozen: return
    growing = false
    $Growing.hide()
    $Grown.show()
