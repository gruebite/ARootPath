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

const Player = preload("res://player/player.tscn")
const Spring = preload("res://entities/spring/spring.tscn")
const PetrifiedTree = preload("res://entities/petrified_tree/petrified_tree.tscn")
const Plant = preload("res://entities/plant/plant.tscn")
const Pit = preload("res://entities/pit/pit.tscn")
const Roots = preload("res://entities/roots/roots.tscn")

export var turn_system_path := NodePath()

var player: Player
var where: int
var cavern_level: int

onready var turn_system := get_node(turn_system_path)
onready var tiles := $Tiles
onready var targeting := $Targeting
onready var entities := $Entities
onready var fog := $FOG
onready var slime_brain = $SlimeBrain

func reset_everything() -> void:
    tiles.clear()
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
            tiles.set_cell(x, y, c)
    tiles.update_bitmask_region(Vector2.ZERO, Vector2(GameState.ISLAND_WIDTH, GameState.ISLAND_HEIGHT))
    # Fix tiles near water.
    for y in GameState.ISLAND_HEIGHT:
        for x in GameState.ISLAND_WIDTH:
            if tiles.get_cell(x, y) == Tile.GROUND:
                var near_void := false
                var near_water := false
                for dir in range(0, Direction.COUNT, 2):
                    var test := Vector2(x, y) + Direction.delta(dir)
                    if tiles.get_cellv(test) == -1:
                        near_void = true
                    elif tiles.get_cellv(test) == Tile.WATER:
                        near_water = true
                if near_water and not near_void:
                    tiles.set_cell(x, y, Tile.GROUND, false, false, false, Vector2(2, 2))
                

    player = Player.instance()
    player.map_position = GameState.return_location
    entities.add_child(player)
    emit_signal("player_entered", player.map_position)

    entities.add_entity_at(Spring.instance(), Vector2(GameState.ISLAND_WIDTH / 2, GameState.ISLAND_HEIGHT / 2))
    entities.add_entity_at(PetrifiedTree.instance(), GameState.petrified_tree_location)

    for mpos in GameState.plant_state:
        entities.add_entity_at(Plant.instance(), mpos)

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

    var pits_to_add: int = CAVERN_PITS[cavern_level]
    while pits_to_add > 0:
        var mpos := walker.opened_tiles.random(Global.rng)
        # Must be far from entrance.
        if entities.get_entity(mpos) or (mpos - Vector2(size / 2, size / 2)).length() < size / 4:
            continue
        entities.add_entity_at(Pit.instance(), mpos)
        pits_to_add -= 1

    var roots_to_add: int = CAVERN_ROOTS[cavern_level]
    while roots_to_add > 0:
        var mpos := walker.opened_tiles.random(Global.rng)
        if entities.get_entity(mpos):
            continue
        entities.add_entity_at(Roots.instance(), mpos)
        roots_to_add -= 1

    player = Player.instance()
    player.map_position = Vector2(size / 2, size / 2)
    entities.add_child(player)
    emit_signal("player_entered", player.map_position)

    fog.unreveal_area(size, size)
    fog.recompute(player.map_position, player.map_position)
    #fog.show()

    slime_brain.spawn_slimes(walker)

func interact(index: int=0) -> void:
    var ent: Entity = entities.get_entity(player.map_position)
    if ent:
        if ent.is_in_group("spring") or ent.is_in_group("pit"):
            warp_cavern()
        elif ent.is_in_group("roots"):
            warp_island()
        elif ent.is_in_group("plant"):
            var plant := ent as Plant
            if plant.water_needed > 0:
                if GameState.water >= plant.water_needed:
                    pass
                else:
                    # :(
                    pass
    else:
        emit_signal("player_interacted", player.map_position, index)

func move_player(to: Vector2) -> void:
    if unwalkable(to): return
    if turn_system.current_turn != TurnSystem.TURN_PLAYER:
        return
    GameState.stop_spell_chain()
        
    var ent: Entity = entities.get_entity(to)
    if ent and ent.is_in_group("slime"):
        ent.damage()
    else:
        var from := player.map_position
        player.map_position = to
        if fog.visible:
            fog.recompute(from, to)
        emit_signal("player_entered", to)
    turn_system.do_turn()

func unwalkable(mpos: Vector2) -> bool:
    return not Tile.walkable(tiles.get_cellv(mpos))

func can_grow_plant(arch_id: String, at: Vector2) -> bool:
    return not unwalkable(at) and tiles.get_cellv(at) != Tile.WATER and entities.get_entity(at) == null

func grow_plant(arch_id: String, at: Vector2) -> void:
    pass
