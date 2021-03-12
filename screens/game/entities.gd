extends YSort
class_name Entities

var lookup := {}

func clear_all() -> void:
    lookup.clear()
    for ent in get_children():
        ent.queue_free()

func add_entity_at(ent, mpos: Vector2) -> void:
    assert(not lookup.has(mpos))
    ent.map_position = mpos
    add_child(ent)
    lookup[ent.map_position] = ent
    ent.connect("died", self, "kill_entity", [ent])

func remove_entity(ent) -> void:
    assert(lookup.has(ent.map_position))
    remove_child(ent)
    lookup.erase(ent.map_position)

func get_entity(mpos: Vector2) -> Node2D:
    return lookup.get(mpos)

func is_an_entity_near(mpos: Vector2) -> bool:
    if get_entity(mpos) != null: return true
    for d in range(0, Direction.COUNT, 2):
        var check := mpos + Direction.delta(d)
        if get_entity(check) != null: return true
    return false

func move_entity(ent, to: Vector2) -> void:
    assert(lookup.has(ent.map_position) and not lookup.has(to))
    lookup.erase(ent.map_position)
    ent.map_position = to
    lookup[to] = ent

func kill_entity(ent) -> void:
    remove_entity(ent)
    ent.queue_free()
