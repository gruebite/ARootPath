extends Control

var selector: Control = null

func _ready() -> void:
    grab_focus()

func _gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if selector:
            selector.hide()
            $container.show()
        else:
            queue_free()
    elif event.is_action_pressed("ui_accept"):
        if selector:
            var island = game.main.current_zone
            island.grow_plant(Plant.CLEAVING_OAK, island.player.zone_position + get_selector_delta())
            queue_free()
        else:
            selector = $up
            selector.show()
            $container.hide()
            check_can_grow()
    elif event.is_action_pressed("ui_up"):
        if selector:
            selector.hide()
            selector = $up
            selector.show()
            check_can_grow()
    elif event.is_action_pressed("ui_down"):
        if selector:
            selector.hide()
            selector = $down
            selector.show()
            check_can_grow()
    elif event.is_action_pressed("ui_left"):
        if selector:
            selector.hide()
            selector = $left
            selector.show()
            check_can_grow()
    elif event.is_action_pressed("ui_right"):
        if selector:
            selector.hide()
            selector = $right
            selector.show()
            check_can_grow()
            
    accept_event()

func check_can_grow() -> void:
    assert(selector)
    var island = game.main.current_zone
    if island.can_grow_at(island.player.zone_position + get_selector_delta()):
        selector.modulate = Color.green
    else:
        selector.modulate = Color.red

func get_selector_delta() -> Vector2:
    assert(selector)
    var delta := Vector2.ZERO
    match selector.name:
        "up": delta = Vector2.UP
        "down": delta = Vector2.DOWN
        "left": delta = Vector2.LEFT
        "right": delta = Vector2.RIGHT
    return delta
