extends Control
class_name Action

signal changed_selection()

enum {
    STATE_INACTIVE,
    STATE_ACTIVE,
    STATE_TARGETING,    
}

export var resources_path := NodePath()
export var info_box_path := NodePath()

var _state := STATE_INACTIVE

var selected := 0
var start_pos := Vector2.ZERO
var target_shape := ShapeCast.new()

onready var resources: Resources = get_node(resources_path)
onready var info_box: InfoBox = get_node(info_box_path)

func _gui_input(event: InputEvent) -> void:
    if _state == STATE_INACTIVE: return
    accept_event()

    if event.is_action_pressed("ui_cancel"):
        _cancel()
        return

    match _state:
        STATE_ACTIVE:
            if event.is_action_pressed("ui_accept"):
                _state = STATE_TARGETING
                init_target()
            elif event.is_action_pressed("ui_up"):
                selected -= 1
                if selected < 0:
                    selected += Plant.COUNT
                update_info()
                emit_signal("changed_selection")
            elif event.is_action_pressed("ui_down"):
                selected = (selected + 1) % Plant.COUNT
                update_info()
                emit_signal("changed_selection")
        STATE_TARGETING:
            if event.is_action_pressed("ui_accept"):
                if try_confirm():
                    _cancel()
            elif event.is_action_pressed("ui_up"):
                update_target(Direction.NORTH)
            elif event.is_action_pressed("ui_down"):
                update_target(Direction.SOUTH)
            elif event.is_action_pressed("ui_left"):
                update_target(Direction.WEST)
            elif event.is_action_pressed("ui_right"):
                update_target(Direction.EAST)


func perform(at: Vector2, index: int=-1) -> void:
    grab_focus()
    _state = STATE_ACTIVE
    if index >= 0:
        selected = index
    start_pos = at
    update_info()

func try_confirm() -> bool:
    pass
    return true
    
func init_target() -> void:
    pass

func update_target(_dir: int) -> void:
    pass

func update_info() -> void:
    pass

func _cancel() -> void:
    _state = STATE_INACTIVE
    release_focus()
    Global.space.targeting.clear()
    resources.charges.highlight()
    
    info_box.hide_all()
