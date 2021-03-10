extends Entity

const MAX_HEALTH := 15

func bump() -> void:
    zone.kill_entity(self)
