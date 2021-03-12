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
    "Remove slime in a line.",
    "Remove slime at a visible location.",
    "Teleport to a visible location.",
    "Freeze slime in an area.",
    "Remove slime and walls in an area."
]

const GROWING_TEXTURES := [
    preload("res://entities/plant/growing/tree.tres"),
    preload("res://entities/plant/growing/bush.tres"),
    preload("res://entities/plant/growing/flower.tres"),
    preload("res://entities/plant/growing/fungus.tres"),
    preload("res://entities/plant/growing/moss.tres"),
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
    if get_age() < get_arch().growth_period:
        $Sprite.texture = GROWING_TEXTURES[get_arch().kind]
    else:
        $Sprite.texture = ARCHS[get_arch_id()].texture

func get_state() -> Dictionary:
    var state = GameState.plant_state[map_position]
    return state

func get_arch_id() -> String:
    return get_state()["id"]

func get_age() -> int:
    return get_state()["age"]

func get_last_watered() -> int:
    return get_state()["last_watered"]

func get_arch() -> PlantArch:
    return ARCHS[get_arch_id()]
    
func needs_water() -> bool:
    return false
