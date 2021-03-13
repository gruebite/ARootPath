extends Entity
class_name SlimeBase

const Smoke = preload("res://entities/slime/smoke/smoke.tscn")

var brain
var frozen := false

func damage() -> void:
    # FIXME
    var ent = Smoke.instance()
    ent.position = map_position * 16
    Global.space.effects.add_child(ent)
    emit_signal("died")

func unfreeze() -> void:
    frozen = false

func freeze() -> void:
    frozen = true
