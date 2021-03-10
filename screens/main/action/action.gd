extends Control

const TEXTS = [
    "[color=red]TREE[/color]\nDEALS DAMAGE IN AN AREA AROUND THE WISP.",
    "[color=red]BUSH[/color]\nDEALS DAMAGE IN A LINE.",
    "[color=red]FLOWER[/color]\nDASHES IN A LINE.",
    "[color=red]FUNGUS[/color]\nFREEZES IN A CONE.",
    "[color=red]MOSS[/color]\nCREATES A BARRIER OR DESTROYS A WALL.",
]

var shape := ShapeCast.new()

var spots := []

var selecting := 0

var targeting := false

func _ready() -> void:
    grab_focus()
    $items/kinds.get_child(selecting).modulate = Color.blue

func _gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if targeting:
            game.main.current_zone.targeting.clear()
            $items.show()
            targeting = false
        else:
            queue_free()
    elif event.is_action_pressed("ui_accept"):
        if targeting:
            if get_targeting_kind() == Targeting.Kind.YES:
                var island = game.main.current_zone
                island.grow_plant(Plant.OAK, spots[0])
                game.main.current_zone.targeting.clear()
                queue_free()
            else:
                game.main.show_message(["Cannot plant tree."], funcref(self, "grab_focus"))
        else:
            targeting = true
            $items.hide()
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.NORTH)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
    elif event.is_action_pressed("ui_up"):
        if targeting:
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.NORTH)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
    elif event.is_action_pressed("ui_down"):
        if targeting:
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.SOUTH)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
    elif event.is_action_pressed("ui_left"):
        if targeting:
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.WEST)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
        else:
            $items/kinds.get_child(selecting).modulate = Color.white
            selecting = (selecting - 1) % 5
            if selecting < 0: selecting += 5
            $items/kinds.get_child(selecting).modulate = Color.blue
            $items/container/margin/label.bbcode_text = TEXTS[selecting]
    elif event.is_action_pressed("ui_right"):
        if targeting:
            spots = shape.cast(game.main.current_zone.player.zone_position, ShapeCast.Direction.EAST)
            game.main.current_zone.targeting.clear()
            game.main.current_zone.targeting.add_points(spots, get_targeting_kind())
        else:
            $items/kinds.get_child(selecting).modulate = Color.white
            selecting = (selecting + 1) % 5
            $items/kinds.get_child(selecting).modulate = Color.blue
            $items/container/margin/label.bbcode_text = TEXTS[selecting]
            
    accept_event()

func get_targeting_kind() -> int:
    assert(targeting)
    var island = game.main.current_zone
    if island.can_grow_at(spots[0]):
        return Targeting.Kind.YES
    else:
        return Targeting.Kind.NO
