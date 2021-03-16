extends Entity

signal finished_thinking()

const FLAVOR := [
    "'...'",
    "'...'",
    "'...'",
    "'...'",
    "'...'",
    "'...'",
    "'...'",
    "'...'",
    "'...'",
    "'So peaceful.'",
    "The slime is meditating.",
]

const MOVE_CHANCE := 0.1

var space

var stepped_on := false

func get_dialog() -> String:
    stepped_on = true
    
    # First general tips.
    if not GameState.friendly_slime_state.has("intro"):
        GameState.friendly_slime_state["intro"] = true
        return "'Hi! Don't step on bad slimes. I'm good.'"
    if GameState.water > 3 and not GameState.has_spell_charges():
        return "'You have water, but no plants.'"
    if GameState.dive_count == 0:
        return "'I came from the cavern. It's better up here.'"
    if GameState.friendly_slime_state.has("death") and GameState.death_count > 0:
        GameState.friendly_slime_state["death"] = true
        return "'You stepped on a bad slime.'"
    if not GameState.watered_petrified_tree:
        return "'The petrified tree wants water.'"
    if GameState.a_plant_needs_water():
        return "'Some plants here look parched.'"
        
    # Flavor.
    if GameState.total_spell_charges() > 20 and not GameState.friendly_slime_state.has("so_many"):
        GameState.friendly_slime_state["so_many"] = true
        return "'So many plants!'"
    if GameState.dive_count > 5 and not GameState.friendly_slime_state.has("scary"):
        GameState.friendly_slime_state["scary"] = true
        return "'It's scary down there.'"
    if GameState.cavern_levels_reached[1] and not GameState.friendly_slime_state.has("fiends"):
        GameState.friendly_slime_state["fiends"] = true
        return "'I did't like it when fiends threw me.'"
    if GameState.cavern_levels_reached[2] and not GameState.friendly_slime_state.has("final"):
        GameState.friendly_slime_state["final"] = true
        return "'Be careful on the last level.'"
    if GameState.saw_demon and not GameState.friendly_slime_state.has("demon_shiver"):
        GameState.friendly_slime_state["demon_shiver"] = true
        return "The slime is shivering."
    if GameState.saw_demon and not GameState.friendly_slime_state.has("demon"):
        GameState.friendly_slime_state["demon"] = true
        return "'Grow more to challenge the demon slime.'"
        
    return FLAVOR[Global.rng.randi_range(0, len(FLAVOR) - 1)]
    
func think() -> void:
    emit_signal("finished_thinking")
    if stepped_on or Global.rng.randf() >= MOVE_CHANCE:
        stepped_on = false
        return

    var dir: int = Global.rng.randi_range(0, 3) * 2
    var vec := map_position + Direction.delta(dir)
    if space.is_free(vec):
        space.entities.move_entity(self, vec)
