extends Entity
class_name SlimeBase

const Droplet = preload("res://entities/slime/droplet/droplet.tscn")
const Smoke = preload("res://entities/slime/smoke/smoke.tscn")

var brain
var frozen := false

func poof() -> void:
    var ent = Smoke.instance()
    ent.position = map_position * 16
    Global.space.effects.add_child(ent)

func release_water(chance: float) -> void:
    if Global.rng.randf() < chance:
        var ent = Droplet.instance()
        ent.position = map_position * 16
        Global.space.effects.add_child(ent)
    emit_signal("died")

func damage() -> void:
    poof()
    release_water(0.5)

func unfreeze() -> void:
    frozen = false

func freeze() -> void:
    frozen = true
