extends Entity
class_name Plant

enum {
    TREE,
    BUSH,
    FLOWER,
    FUNGUS,
    MOSS,    
}

const COUNT := 5

const SPELLS := [
    "Removes slime in a line.",
    "Removes slime at a visible location.",
    "Teleports to a visible location.",
    "Freezes slime in an area.",
    "Removes slime and walls in a small area."
]

const GROWING_TEXTURES := [
    preload("res://entities/plant/growing/tree.tres"),
]

const KIND_ARCH_IDS = {
    TREE: ["Tree"],
    BUSH: ["Bush"],
    FLOWER: ["Flower"],
    FUNGUS: ["Fungus"],
    MOSS: ["Moss"],
}

const ARCHS = {
    "Tree": preload("res://entities/plant/arch/tree.tres"),
    "Bush": preload("res://entities/plant/arch/bush.tres"),
    "Flower": preload("res://entities/plant/arch/flower.tres"),
    "Fungus": preload("res://entities/plant/arch/fungus.tres"),
    "Moss": preload("res://entities/plant/arch/moss.tres"),
}

func _ready() -> void:
    # TODO: Update sprite/info based on state.
    pass

func get_state() -> Dictionary:
    var state = GameState.plant_state[map_position]
    return state

func get_arch_id() -> String:
    return get_state()["id"]

func get_age() -> String:
    return get_state()["age"]

func get_last_watered() -> String:
    return get_state()["last_watered"]

func get_arch() -> PlantArch:
    return ARCHS[get_arch_id()]
    
func needs_water() -> bool:
    return false
