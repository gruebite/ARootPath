extends Control

func _ready() -> void:
    grab_focus()

func _gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        queue_free()
    elif event.is_action_pressed("ui_accept"):
        pass
    elif event.is_action_pressed("ui_up"):
        pass
    elif event.is_action_pressed("ui_down"):
        pass
    elif event.is_action_pressed("ui_left"):
        pass
    elif event.is_action_pressed("ui_right"):
        pass
    accept_event()
