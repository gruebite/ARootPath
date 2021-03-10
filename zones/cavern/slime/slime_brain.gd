extends Node2D

enum {
    SLIME_LEECH,
    SLIME_GROWING,
    SLIME_GROWN,
}

const LEECH_COUNT := [12, 24, 36]

const FOOD_RATE := [2, 3, 5]
const FOOD_LIFE := [13, 21, 34]

const LEECH := preload("res://zones/cavern/slime/leech.tscn")
const SLIME := preload("res://zones/cavern/slime/slime.tscn")

var zone: Zone = null
var level: int = 0

var slimes := {}
var food := {}

func cleanup() -> void:
    slimes.clear()
    food.clear()

func spawn_leeches(walker: Walker) -> void:
    var leeches_to_add = LEECH_COUNT[level]
    while leeches_to_add > 0:
        var pos := walker.opened_tiles.random(game.rng)
        if zone.get_entity_at(pos) == null:
            grow_leech(pos)
            leeches_to_add -= 1

func take_turn() -> void:
    var start_life: int = FOOD_LIFE[level]
    # Spawn food.
    for i in FOOD_RATE[level]:
        var d: int = game.rng.randi_range(0, Direction.COUNT)
        food[zone.player.zone_position + Direction.delta(d)] = start_life
    
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
            if slimes.has(test) and Direction.is_cardinal(d):
                grow_slime(pos)
                consumed = true
                break
            if not zone.unwalkable(test) and zone.get_entity_at(test) == null:
                candidates.append(test)
        if not consumed:
            var new_pos: Vector2 = pos
            if len(candidates) > 0:
                candidates.shuffle()
                new_pos = candidates[0]
            new_food[new_pos] = life
    food = new_food
    
func grow_leech(at: Vector2) -> void:
    var slime := LEECH.instance()
    zone.add_entity_at(slime, at)
    slimes[at] = SLIME_LEECH
    
func grow_slime(at: Vector2) -> void:
    var slime := SLIME.instance()
    zone.add_entity_at(slime, at)
    slimes[at] = SLIME_GROWING
    
func grow_adult_slime(at: Vector2) -> void:
    var slime := SLIME.instance()
    zone.add_entity_at(slime, at)
    slimes[at] = SLIME_GROWN

func kill_slime(at: Vector2) -> int:
    var kind = slimes.get(at)
    if kind == null:
        return -1
    zone.remove_entity_at(at)
    slimes.erase(at)
    return kind
