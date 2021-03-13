extends CanvasLayer

export var space_path := NodePath()

onready var space: Space = get_node(space_path)

func _on_Space_player_entered(at: Vector2) -> void:
    var entities: Entities = space.entities
    var ent := entities.get_entity(at)
    if ent:
        if ent.is_in_group("spring"):
            $Root/InfoBox.display_simple("SPRING. CAVERN ENTRANCE.")
        elif ent.is_in_group("petrified_tree"):
            $Root/InfoBox.display_simple("PETRIFIED TREE. ITS ROOTS GO DEEP.")
        elif ent.is_in_group("roots"):
            $Root/InfoBox.display_simple("PETRIFIED ROOTS. REACHES SURFACE.")
        elif ent.is_in_group("pit"):
            $Root/InfoBox.display_simple("DEEP PIT. ONE WAY.")
        elif ent.is_in_group("plant"):
            $Root/InfoBox.display_plant(ent as Plant)
    elif space.objects.get_cellv(at) == Tile.SLIMY_WATER:
        $Root/InfoBox.display_simple("SLIMY WATER.")
    elif space.objects.get_cellv(at) == Tile.PURIFIED_WATER:
        $Root/InfoBox.display_simple("PURIFIED WATER.")
    else:
        $Root/InfoBox.hide_all()

# Interacted on an empty space.
func _on_Space_player_interacted(at: Vector2, index: int=-1) -> void:
    if space.where == Space.ISLAND:
        $Root/Grow.perform(at, index)
    elif space.where == Space.CAVERN:
        $Root/Cast.perform(at, index)

func _on_water_changed(to: int) -> void:
    $Root/Resources.water.change(to)

func _on_spell_charge_changed(kind: int, to: int) -> void:
    $Root/Resources.charges.change(kind, to)

func _on_spell_chained(amount: int) -> void:
    pass

func _on_spell_chain_stopped() -> void:
    pass
