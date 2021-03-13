extends SlimeBase

var growing := true

func _ready() -> void:
    $Growing.play("spawn")
    yield($Growing, "animation_finished")
    $Growing.play("idle")

func grow_up() -> void:
    assert(growing)
    if frozen: return
    growing = false
    $Growing.hide()
    $Grown.show()
    $Grown.play("spawn")
    yield($Grown, "animation_finished")
    $Grown.play("idle")

func unfreeze() -> void:
    .unfreeze()
    $Growing.playing = true
    $Grown.playing = true

func freeze() -> void:
    .freeze()
    $Growing.playing = false
    $Grown.playing = false
