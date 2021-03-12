extends Control

export var resources_path := NodePath()
export var info_box_path := NodePath()

onready var resources: Resources = get_node(resources_path)
onready var info_box: InfoBox = get_node(info_box_path)

var active := false
var selected := 0
var origin := Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
    if not active: return
    accept_event()
    
    if event.is_action_pressed("ui_cancel"):
        active = false
        release_focus()
        info_box.hide_all()
        resources.charges.deselect()
        return
        
    if event.is_action_pressed("ui_up"):
        selected -= 1
        if selected < 0:
            selected += Plant.COUNT
        info_box.display_simple(Plant.SPELLS[selected])
        resources.charges.select(selected)
    elif event.is_action_pressed("ui_down"):
        selected = (selected + 1) % Plant.COUNT
        info_box.display_simple(Plant.SPELLS[selected])
        resources.charges.select(selected)
    
func perform(at: Vector2, index: int=0) -> void:
    grab_focus()
    active = true
    selected = index
    origin = at
    info_box.display_simple(Plant.KIND_RESOURCES[selected].spell_description)
    resources.charges.select(selected)
    
