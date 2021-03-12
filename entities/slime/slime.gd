extends Entity

var growing := true

func grow_up() -> void:
    assert(growing)
    growing = false
    $Growing.hide()
    $Grown.show()

func damage() -> void:
    emit_signal("died")
