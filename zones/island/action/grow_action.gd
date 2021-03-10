extends Control

var shape := ShapeCast.new()

var spots := []

var selecting := false

func _ready() -> void:
    grab_focus()

func _gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if selecting:
            game.main.current_zone.targeting.clear()
            $container.show()
            selecting = false
        else:
            queue_free()
    elif event.is_action_pressed("ui_accept"):
        if selecting:
            if get_targeting_kind() == Targeting.Kind.YES:
                var island = game.main.current_zone
                island.grow_plant(Plant.CLEAVING_OAK, spots[0])
                game.main.current_zone.targeting.clear()
                queue_free()
            else:
                game.main.show_message(["Cannot plant tree."], funcref(self, "grab_focus"))
        else:
            selecting = true
            $container.hide()
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.NORTH)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
    elif event.is_action_pressed("ui_up"):
        if selecting:
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.NORTH)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
    elif event.is_action_pressed("ui_down"):
        if selecting:
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.SOUTH)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
    elif event.is_action_pressed("ui_left"):
        if selecting:
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.WEST)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
    elif event.is_action_pressed("ui_right"):
        if selecting:
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.EAST)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
            
    accept_event()

func get_targeting_kind() -> int:
    assert(selecting)
    var island = game.main.current_zone
    if island.can_grow_at(spots[0]):
        return Targeting.Kind.YES
    else:
        return Targeting.Kind.NO
