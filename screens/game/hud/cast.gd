extends Action

func try_confirm() -> bool:
    var area := target_shape.cast()
    if Global.space.can_cast_spell(selected, area):
        Global.space.cast_spell(selected, area)
        return true
    return false
    
func init_target() -> void:
    target_shape.origin = start_pos
    update_target(Direction.NORTH)

func update_target(dir: int) -> void:
    Global.space.targeting.clear()
    target_shape.direction = dir
    var area := target_shape.cast()
    if Global.space.can_cast_spell(selected, area):
        Global.space.targeting.set_cellv(area[0], 1)
    else:
        Global.space.targeting.set_cellv(area[0], 0)

func update_info() -> void:
    info_box.display_simple(Plant.KIND_RESOURCES[selected].spell_description)
    resources.charges.select(selected)
