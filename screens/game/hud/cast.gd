extends Action

func try_confirm() -> bool:
    var area := target_shape.cast()
    if Global.space.can_cast_spell(selected, area):
        Global.space.cast_spell(selected, area)
        return true
    return false

func init_target() -> void:
    info_box.hide_all()
    target_shape.origin = start_pos
    match selected:
        Plant.Kind.TREE:
            target_shape.size = 5
            target_shape.kind = ShapeCast.Kind.LINE
            update_target(Direction.NORTH)
        Plant.Kind.BUSH:
            target_shape.size = 1
            target_shape.kind = ShapeCast.Kind.POINT
            update_target(Direction.NORTH)
        Plant.Kind.FLOWER:
            target_shape.size = 1
            target_shape.kind = ShapeCast.Kind.POINT
            update_target(Direction.NORTH)
        Plant.Kind.FUNGUS:
            target_shape.size = 5
            target_shape.kind = ShapeCast.Kind.CIRCLE
            update_target(-1)
        Plant.Kind.MOSS:
            target_shape.size = 2
            target_shape.kind = ShapeCast.Kind.CIRCLE
            update_target(-1)

func update_target(dir: int) -> void:
    Global.space.targeting.clear()
    match selected:
        Plant.Kind.TREE:
            target_shape.direction = dir
        Plant.Kind.BUSH:
            target_shape.origin += Direction.delta(dir)
        Plant.Kind.FLOWER:
            target_shape.origin += Direction.delta(dir)
        Plant.Kind.FUNGUS:
            target_shape.direction = -1
        Plant.Kind.MOSS:
            target_shape.direction = -1
    var target_type = 0
    var area := target_shape.cast()
    if Global.space.can_cast_spell(selected, area):
        target_type = 1
    for pos in area:
        Global.space.targeting.set_cellv(pos, target_type)

func update_info() -> void:
    info_box.display_simple(Plant.KIND_RESOURCES[selected].spell_description)
    resources.charges.highlight(selected)
