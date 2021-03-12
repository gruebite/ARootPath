extends Control

export var resources_path := NodePath()
export var info_box_path := NodePath()

onready var resources: Resources = get_node(resources_path)
onready var info_box: InfoBox = get_node(info_box_path)

var active := false
var selected := 0
var subselected := 0

var targeting := false
var target_shape := ShapeCast.new()

func _gui_input(event: InputEvent) -> void:
    if not active: return
    accept_event()

    if event.is_action_pressed("ui_cancel"):
        cancel()
        return

    if targeting:
        _do_targeting(event)
        return

    if event.is_action_pressed("ui_accept"):
        targeting = true
        target(Direction.NORTH)
        return

    if event.is_action_pressed("ui_up"):
        selected -= 1
        if selected < 0:
            selected += Plant.COUNT
        subselected %= len(Plant.KIND_ARCH_IDS[selected])
        _update_info()
    elif event.is_action_pressed("ui_down"):
        selected = (selected + 1) % Plant.COUNT
        subselected %= len(Plant.KIND_ARCH_IDS[selected])
        _update_info()
    elif event.is_action_pressed("ui_left"):
        subselected -= 1
        if subselected < 0:
            subselected += len(Plant.KIND_ARCH_IDS[selected])
        _update_info()
    elif event.is_action_pressed("ui_right"):
        subselected = (subselected + 1) % len(Plant.KIND_ARCH_IDS[selected])
        _update_info()

func cancel() -> void:
    active = false
    targeting = false
    release_focus()
    info_box.hide_all()
    resources.charges.deselect()
    Global.space.targeting.clear()

func confirm() -> void:
    var location: Vector2 = target_shape.cast()[0]
    if Global.space.can_grow_plant(Plant.KIND_ARCH_IDS[selected][subselected], location):
        Global.space.grow_plant(Plant.KIND_ARCH_IDS[selected][subselected], location)
        cancel()

func target(dir: int) -> void:
    Global.space.targeting.clear()
    target_shape.direction = dir
    var location: Vector2 = target_shape.cast()[0]
    if Global.space.can_grow_plant(Plant.KIND_ARCH_IDS[selected][subselected], location):
        Global.space.targeting.set_cellv(location, 1)
    else:
        Global.space.targeting.set_cellv(location, 0)

func perform(at: Vector2, index: int=0) -> void:
    grab_focus()
    active = true
    selected = index
    target_shape.origin = at
    _update_info()

func _do_targeting(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        confirm()
    elif event.is_action_pressed("ui_up"):
        target(Direction.NORTH)
    elif event.is_action_pressed("ui_down"):
        target(Direction.SOUTH)
    elif event.is_action_pressed("ui_left"):
        target(Direction.WEST)
    elif event.is_action_pressed("ui_right"):
        target(Direction.EAST)

func _update_info() -> void:
    resources.charges.select(selected)
    var arch_id: String = Plant.KIND_ARCH_IDS[selected][subselected]
    var arch: PlantArch = Plant.ARCHS[arch_id]
    var can_afford := arch.grow_cost <= GameState.water
    info_box.display_plant_arch_id(arch_id, can_afford)
