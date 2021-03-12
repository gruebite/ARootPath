extends Node2D
class_name Space

signal player_entered(at)
signal player_interacted(at, index)

enum {
    ISLAND,
    CAVERN,
}

const CAVERN_SIZES := [
    70, 100, 141, 173,
]

const CAVERN_ROOTS := [
    8, 5, 3,
]

const CAVERN_PITS := [
    1, 1, 0,
]

const MIDDLE_COORD := Vector2(2, 2)

const PlayerScene = preload("res://player/player.tscn")
const Spring = preload("res://entities/spring/spring.tscn")
const PetrifiedTree = preload("res://entities/petrified_tree/petrified_tree.tscn")
const PlantScene = preload("res://entities/plant/plant.tscn")
const Pit = preload("res://entities/pit/pit.tscn")
const Roots = preload("res://entities/roots/roots.tscn")

export var turn_system_path := NodePath()
var noise := OpenSimplexNoise.new()

var player: Player
var where: int
var cavern_level: int

onready var turn_system := get_node(turn_system_path)
onready var tiles := $Tiles
onready var objects := $Objects
onready var air := $Air
onready var targeting := $Targeting
onready var entities := $Entities
onready var fog := $FOG
onready var slime_brain = $SlimeBrain

func _ready() -> void:
    noise.period = 4

func reset_everything() -> void:
    tiles.clear()
    objects.clear()
    air.clear()
    targeting.clear()
    entities.clear_all()
    fog.clear()
    slime_brain.cleanup()

func warp_island() -> void:
    reset_everything()
    where = ISLAND
    cavern_level = -1

    # Update plants, calculate spell counts.
    GameState.update_island()

    for y in GameState.ISLAND_HEIGHT:
        for x in GameState.ISLAND_WIDTH:
            var c = GameState.island_tiles[Vector2(x, y)]
            if c >= 0:
                tiles.set_cell(x, y, c)
    tiles.update_bitmask_region()
    post_process(GameState.ISLAND_WIDTH, GameState.ISLAND_HEIGHT)

    var FAIRY_COUNT := 10
    for _i in range(FAIRY_COUNT):
        var x: int = Global.rng.randi_range(0, GameState.ISLAND_WIDTH - 1)
        var y: int = Global.rng.randi_range(0, GameState.ISLAND_HEIGHT - 1)
        air.set_cell(x, y, Tile.FAIRY0 + Global.rng.randi_range(0, 1))

    player = PlayerScene.instance()
    player.map_position = GameState.return_location
    entities.add_child(player)
    emit_signal("player_entered", player.map_position)

    entities.add_entity_at(Spring.instance(), Vector2(GameState.ISLAND_WIDTH / 2, GameState.ISLAND_HEIGHT / 2))
    entities.add_entity_at(PetrifiedTree.instance(), GameState.petrified_tree_location)
    objects.set_cellv(GameState.petrified_tree_location, -1)

    for mpos in GameState.plant_state:
        entities.add_entity_at(PlantScene.instance(), mpos)
        objects.set_cellv(mpos, -1)

    fog.hide()

func warp_cavern() -> void:
    reset_everything()
    where = CAVERN
    cavern_level += 1

    var size: int = CAVERN_SIZES[cavern_level]

    var walker := Walker.new(Global.rng)
    walker.start(size, size)
    walker.goto(size / 2, size / 2)
    walker.mark_plus(Tile.GROUND)
    walker.commit()
    while walker.percent_opened() < 0.6:
        walker.goto_random_opened()
        walker.remember()
        walker.goto_random_closed()
        while not walker.on_opened():
            walker.step_weighted_last(0.7)
            walker.mark_plus(Tile.GROUND)
        walker.commit()
        walker.forget()

    for x in size:
        for y in size:
            fog.set_cell(x, y, 0)
            var c: int = walker.grid[Vector2(x, y)]
            tiles.set_cell(x, y, c)
    tiles.update_bitmask_region(Vector2.ZERO, Vector2(size, size))
    post_process(size, size)

    var pits_to_add: int = CAVERN_PITS[cavern_level]
    while pits_to_add > 0:
        var mpos := walker.opened_tiles.random(Global.rng)
        # Must be far from entrance.
        if entities.get_entity(mpos) or (mpos - Vector2(size / 2, size / 2)).length() < size / 4:
            continue
        entities.add_entity_at(Pit.instance(), mpos)
        objects.set_cellv(mpos, -1)
        pits_to_add -= 1

    var roots_to_add: int = CAVERN_ROOTS[cavern_level]
    while roots_to_add > 0:
        var mpos := walker.opened_tiles.random(Global.rng)
        if entities.get_entity(mpos):
            continue
        entities.add_entity_at(Roots.instance(), mpos)
        objects.set_cellv(mpos, -1)
        roots_to_add -= 1

    player = PlayerScene.instance()
    player.map_position = Vector2(size / 2, size / 2)
    entities.add_child(player)
    emit_signal("player_entered", player.map_position)

    fog.unreveal_area(size, size)
    fog.recompute(player.map_position, player.map_position)
    fog.show()

    slime_brain.spawn_slimes(walker)

func post_process(w: int, h: int) -> void:
    for y in w:
        for x in h:
            var coord: Vector2 = tiles.get_cell_autotile_coord(x, y)
            if coord == MIDDLE_COORD:
                if tiles.get_cell(x, y) == Tile.GROUND:
                    var norm := noise.get_noise_2d(x + 0.5, y + 0.5)
                    if norm < 0.0:
                        var coord_x := int(round((1+norm) * (1+norm) * 6))
                        objects.set_cell(x, y, Tile.GRAVEL, false, false, false, Vector2(coord_x, 0))
                    elif norm >= 0.2:
                        norm = (norm - 0.2) * 2
                        var coord_x := int(round(norm * 5))
                        objects.set_cell(x, y, Tile.GRASS, false, false, false, Vector2(coord_x, 0))
                elif tiles.get_cell(x, y) == Tile.WATER:
                    if Global.rng.randf() < 0.1:
                        objects.set_cell(x, y, Tile.SHIMMER)
                    elif Global.rng.randf() < 0.1:
                        objects.set_cell(x, y, Tile.LILLY)

func interact(index: int=-1) -> void:
    var ent: Entity = entities.get_entity(player.map_position)
    if ent:
        if ent.is_in_group("spring") or ent.is_in_group("pit"):
            warp_cavern()
        elif ent.is_in_group("roots"):
            warp_island()
        elif ent.is_in_group("plant"):
            var plant := ent as Plant
            var needed := plant.get_water_needed()
            if needed > 0:
                if GameState.water >= needed:
                    GameState.set_water(GameState.water - needed)
                else:
                    # :(
                    pass
        elif ent.is_in_group("tainted_water"):
            pass
    else:
        emit_signal("player_interacted", player.map_position, index)

func move_player(to: Vector2, is_turn: bool=true) -> void:
    if unwalkable(to): return
    if turn_system.current_turn != TurnSystem.TURN_PLAYER:
        print("NOT TURN ", turn_system.thinker_count)
        return

    var ent: Entity = entities.get_entity(to)
    if ent and ent.is_in_group("slime"):
        ent.damage()
    else:
        var from := player.map_position
        player.map_position = to
        if fog.visible:
            fog.recompute(from, to)
        emit_signal("player_entered", to)
    
    if is_turn:
        GameState.stop_spell_chain()
        turn_system.do_turn()

func unwalkable(mpos: Vector2) -> bool:
    return not Tile.walkable(tiles.get_cellv(mpos))

func can_afford_plant(kind: int) -> bool:
    return GameState.water >= Plant.KIND_RESOURCES[kind].grow_cost

func can_grow_plant(kind: int, at: Vector2) -> bool:
    return can_afford_plant(kind) and not unwalkable(at) and tiles.get_cellv(at) != Tile.WATER and _has_space_for_plant(kind, at)

func grow_plant(kind: int, at: Vector2) -> void:
    assert(can_grow_plant(kind, at))
    GameState.modify_water(-Plant.KIND_RESOURCES[kind].grow_cost)
    GameState.plant_state[at] = {
        "kind": kind,
        "age": 0,
        "last_watered": 0,
    }
    objects.set_cellv(at, -1)
    entities.add_entity_at(PlantScene.instance(), at)


func can_cast_spell(kind: int, area: Array) -> bool:
    if GameState.spell_charges[kind] == 0:
        return false
    if GameState.chain_count >= GameState.water:
        return false
    match kind:
        Plant.Kind.TREE:
            return true
        Plant.Kind.BUSH:
            return not unwalkable(area[0]) and not entities.get_entity(area[0]) and fog.is_revealed(area[0])
        Plant.Kind.FLOWER:
            return not unwalkable(area[0]) and fog.is_revealed(area[0])
        Plant.Kind.FUNGUS:
            return true
        Plant.Kind.MOSS:
            return true
    return false

func cast_spell(kind: int, area: Array) -> void:
    assert(can_cast_spell(kind, area))
    match kind:
        Plant.Kind.TREE:
            for pos in area:
                if fog.is_revealed(pos):
                    var slime = entities.get_entity(pos)
                    if slime and slime.is_in_group("slime"):
                        slime.damage()
        Plant.Kind.BUSH:
            var slime = entities.get_entity(area[0])
            if slime and slime.is_in_group("slime"):
                slime.damage()
        Plant.Kind.FLOWER:
            move_player(area[0], false)
        Plant.Kind.FUNGUS:
            if fog.is_revealed(area[0]):
                slime_brain.freeze_spot(area[0])
        Plant.Kind.MOSS:
            for pos in area:
                if fog.is_revealed(pos):
                    var slime = entities.get_entity(area[0])
                    if slime and slime.is_in_group("slime"):
                        slime.damage()
                    elif tiles.get_cellv(pos) == -1:
                        tiles.set_cellv(pos, Tile.GROUND)
                        tiles.update_bitmask_area(pos)
                        move_player(player.map_position, false)
    GameState.modify_water(-GameState.chain_count)
    GameState.use_spell_charge(kind)
    GameState.chain_spell()

func _has_space_for_plant(kind: int, at: Vector2) -> bool:
    if entities.get_entity(at) != null: return true
    var required: int = Plant.KIND_RESOURCES[kind].space_needed
    for d in range(0, Direction.COUNT, 2):
        var check := at + Direction.delta(d)
        var other = entities.get_entity(check)
        if other != null:
            if other.is_in_group("plant"):
                if required == 1 or other.get_resource().space_needed == 1:
                    return false
            else:
                return false
    return true
