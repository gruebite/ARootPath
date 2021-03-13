extends Node2D
class_name SlimeBrain

signal slime_grew(mpos)
signal slime_finished_thinking()

enum {
    SLIME_DEMON,
    SLIME_SPREADER,
    SLIME_GROWING,
    SLIME_GROWN,
}

const FROST_TIMER := 3

const DEMON_COUNT := [0, 0, 1]
const FIEND_COUNT := [0, 6, 12]
const SLIME_COUNT := [12, 18, 24]

const FOOD_RATE := [2, 3, 5]
const FOOD_LIFE := [13, 21, 34]

const Demon := preload("res://entities/slime/demon.tscn")
const Fiend := preload("res://entities/slime/fiend.tscn")
const Slime := preload("res://entities/slime/slime.tscn")

export var space_path := NodePath()

var slimes := {}
var frost := {}
var food := {}

onready var space: Space = get_node(space_path)

func cleanup() -> void:
    slimes.clear()
    frost.clear()
    food.clear()

func spawn_slimes(walker: Walker) -> void:
    var slime_to_add: int = SLIME_COUNT[space.cavern_level]
    var fiends_to_add: int = FIEND_COUNT[space.cavern_level]
    var demons_to_add: int = DEMON_COUNT[space.cavern_level]
    while slime_to_add > 0 or fiends_to_add > 0 or demons_to_add > 0:
        var pos: Vector2 = walker.opened_tiles.random(Global.rng)
        if not space.entities.get_entity(pos):
            # Normalized distance based on map.  Demon can only be spawned far away from entrance.
            var dist_n: float = (((pos / Vector2(walker.width, walker.height)).normalized() * 2) - Vector2.ONE).length()
            if demons_to_add > 0 and dist_n > 0.5:
                demons_to_add -= 1
                grow_demon(pos)
            elif fiends_to_add > 0 and dist_n > 0.2:
                fiends_to_add -= 1
                grow_fiend(pos)
            elif slime_to_add > 0:
                slime_to_add -= 1
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
    var grew := false
    for pos in slimes:
        if slimes[pos] == SLIME_GROWING:
            var f_amount = frost.get(pos)
            if f_amount != null:
                f_amount = int(max(0, f_amount - 1))
                if f_amount == 0:
                    frost.erase(pos)
                    space.entities.get_entity(pos).unfreeze()
                else:
                    frost[pos] = f_amount
            if f_amount == null or f_amount == 0:
                slimes[pos] = SLIME_GROWN
                emit_signal("slime_grew", pos)
                var slime: Entity = space.entities.get_entity(pos)
                slime.grow_up()
                grew = true
    if grew and not $Grew.playing:
        $Grew.play()

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
            var neigh := (pos as Vector2) + delta
            # Only grow slimes in cardinal direction, but move food in all.
            # Only grow from non-growing slime to prevent explosive growth.
            if slimes.has(neigh) and slimes.get(neigh) != SLIME_GROWING and Direction.is_cardinal(d) and space.is_free(pos):
                # Consume the food.
                consumed = true
                var f_amount = frost.get(neigh)
                # Skip if this slime is frozen, but lower freeze level.
                if f_amount != null:
                    f_amount = int(max(0, f_amount - 1))
                    if f_amount == 0:
                        frost.erase(neigh)
                        space.entities.get_entity(neigh).unfreeze()
                    else:
                        frost[neigh] = f_amount
                else:
                    grow_slime(pos)
                break
            if not space.unwalkable(neigh):
                candidates.append(neigh)
        # If this food wasn't consumed, move it to a random location.
        if not consumed:
            var new_pos: Vector2 = pos
            if len(candidates) > 0:
                candidates.shuffle()
                new_pos = candidates[0]
            new_food[new_pos] = life

    food = new_food

func grow_demon(at: Vector2) -> void:
    assert(space.is_free(at))
    var slime := Demon.instance()
    slime.visible = space.fog.is_revealed(at)
    slime.brain = self
    space.entities.add_entity_at(slime, at)
    slimes[at] = SLIME_DEMON
    slime.connect("finished_thinking", self, "_finished_thinking")
    slime.connect("died", self, "_slime_died", [slime])

func grow_fiend(at: Vector2) -> void:
    assert(space.is_free(at))
    var slime := Fiend.instance()
    slime.visible = space.fog.is_revealed(at)
    slime.brain = self
    space.entities.add_entity_at(slime, at)
    slimes[at] = SLIME_SPREADER
    slime.connect("finished_thinking", self, "_finished_thinking")
    slime.connect("died", self, "_slime_died", [slime])

func grow_slime(at: Vector2) -> void:
    assert(space.is_free(at))
    var slime := Slime.instance()
    slime.visible = space.fog.is_revealed(at)
    space.entities.add_entity_at(slime, at)
    slimes[at] = SLIME_GROWING
    slime.connect("died", self, "_slime_died", [slime])

func remove_slime(at: Vector2) -> int:
    # Entity removal/freeing should be handled separately.
    var kind = slimes.get(at)
    if kind == null:
        return -1
    slimes.erase(at)
    frost.erase(at)
    return kind

func move_slime(at: Vector2, to: Vector2) -> void:
    var slime = slimes.get(at)
    assert(slime != null and space.is_free(to))
    space.entities.move_entity(space.entities.get_entity(at), to)
    slimes.erase(at)
    slimes[to] = slime
    var f = frost.get(at)
    if f:
        frost.erase(at)
        frost[to] = f

func freeze_spot(at: Vector2) -> void:
    if not slimes.get(at): return
    # Definitely slime.
    space.entities.get_entity(at).freeze()
    frost[at] = FROST_TIMER

func _slime_died(slime: Entity) -> void:
    remove_slime(slime.map_position)

func _finished_thinking() -> void:
    emit_signal("slime_finished_thinking")
