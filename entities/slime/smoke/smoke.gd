extends AnimatedSprite

func _ready() -> void:
    frame = 0
    yield(self, "animation_finished")
    queue_free()
