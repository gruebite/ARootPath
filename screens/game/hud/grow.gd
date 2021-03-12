extends Action

func try_confirm() -> bool:
    var location: Vector2 = target_shape.cast()[0]
    if Global.space.can_grow_plant(selected, location):
        Global.space.grow_plant(selected, location)
        return true
    return false
    
func init_target() -> void:
    target_shape.origin = start_pos
    update_target(Direction.NORTH)

func update_target(dir: int) -> void:
    Global.space.targeting.clear()
    target_shape.direction = dir
    var location: Vector2 = target_shape.cast()[0]
    if Global.space.can_grow_plant(selected, location):
        Global.space.targeting.set_cellv(location, 1)
    else:
        Global.space.targeting.set_cellv(location, 0)

func update_info() -> void:
    resources.charges.select(selected)
    var res: PlantResource = Plant.KIND_RESOURCES[selected]
    var can_afford: bool = res.grow_cost <= GameState.water
    info_box.display_plant_kind(selected, can_afford)
