extends Entity
class_name SlimeBase

var brain
var frozen := false

func damage() -> void:
    emit_signal("died")

func unfreeze() -> void:
    frozen = false

func freeze() -> void:
    pass
