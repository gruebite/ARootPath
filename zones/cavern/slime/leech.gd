extends Entity

const MAX_HEALTH := 3

var health := MAX_HEALTH

func bump() -> void:
    health -= 1
    if health <= 0:
        queue_free()
