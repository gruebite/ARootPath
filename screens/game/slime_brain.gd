extends Node2D
class_name SlimeBrain

signal slime_grew(mpos)
signal slime_finished_thinking()

enum {
    SLIME_LEECH,
    SLIME_GROWING,
    SLIME_GROWN,
}

const SLIME_COUNT := [12, 24, 36]

const FOOD_RATE := [2, 3, 5]
const FOOD_LIFE := [13, 21, 34]

const Leech := preload("res://entities/slime/leech.tscn")
const Slime := preload("res://entities/slime/slime.tscn")

export var space_path := NodePath()

var slimes := {}
var food := {}

onready var space: Space = get_node(space_path)

func cleanup() -> void:
    slimes.clear()
    food.clear()

func spawn_slimes(walker: Walker) -> void:
    var to_add: int = SLIME_COUNT[space.cavern_level] * 3
    for i in to_add:
        var pos := (Util.r2(i + 1) * Vector2(walker.width, walker.height)).floor()
        if walker.opened_tiles.hasv(pos) and space.entities.get_entity(pos) == null:
            if i % 3 == 0:
                grow_leech(pos)
            else:
                grow_slime(pos)

func take_turn() -> void:
    if space.where != Space.CAVERN:
        return
        
    var start_life: int = FOOD_LIFE[space.cavern_level]
    # Spawn food.
    for i in FOOD_RATE[space.cavern_level]:
        var d: int = Global.rng.randi_range(0, Direction.COUNT + 4)
        food[space.player.map_position + Direction.delta(d)] = start_life
        
    # Upgrade growing slimes.
    for pos in slimes:
        if slimes[pos] == SLIME_GROWING:
            slimes[pos] = SLIME_GROWN
            emit_signal("slime_grew", pos)
            var slime: Entity = space.entities.get_entity(pos)
            slime.grow_up()
    
    var new_food := {}
    var candidates := []
    for pos in food:
        var life: int = food[pos]
        life -= 1
        if life <= 0:
            # Food gone.
            continue
        # Move food.
        candidates.clear()
        var consumed := false
        for d in Direction.COUNT:
            var delta := Direction.delta(d)
            var test := (pos as Vector2) + delta
            # Only grow slimes in cardinal direction, but move food in all.
            if slimes.has(test) and Direction.is_cardinal(d) and not space.unwalkable(pos) and space.entities.get_entity(pos) == null:
                grow_slime(pos)
                consumed = true
                break
            if not space.unwalkable(test):
                candidates.append(test)
        if not consumed:
            var new_pos: Vector2 = pos
            if len(candidates) > 0:
                candidates.shuffle()
                new_pos = candidates[0]
            new_food[new_pos] = life
        
    food = new_food
    
func grow_demon(at: Vector2) -> void:
    var slime := Leech.instance()
    space.entities.add_entity_at(slime, at)
    slimes[at] = SLIME_LEECH
    slime.connect("finished_thinking", self, "_finished_thinking")
    slime.connect("died", self, "_slime_died", [slime])
    
func grow_leech(at: Vector2) -> void:
    var slime := Leech.instance()
    space.entities.add_entity_at(slime, at)
    slimes[at] = SLIME_LEECH
    slime.connect("finished_thinking", self, "_finished_thinking")
    slime.connect("died", self, "_slime_died", [slime])
    
func grow_slime(at: Vector2) -> void:
    var slime := Slime.instance()
    space.entities.add_entity_at(slime, at)
    slimes[at] = SLIME_GROWING
    slime.connect("died", self, "_slime_died", [slime])

func remove_slime(at: Vector2) -> int:
    # Entity removal/freeing should be handled separately.
    var kind = slimes.get(at)
    if kind == null:
        return -1
    slimes.erase(at)
    return kind

func _slime_died(slime: Entity) -> void:
    remove_slime(slime.map_position)

func _finished_thinking() -> void:
    emit_signal("slime_finished_thinking")
