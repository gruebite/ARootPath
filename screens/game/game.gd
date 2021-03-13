extends Node2D
class_name Game

func _ready() -> void:
    Global.space = $Space
    GameState.connect("water_changed", $HUD, "_on_water_changed")
    GameState.connect("spell_charge_changed", $HUD, "_on_spell_charge_changed")
    GameState.connect("spell_chained", $HUD, "_on_spell_chained")
    GameState.connect("spell_chain_stopped", $HUD, "_on_spell_chain_stopped")
    GameState.new_game()
    $Space.warp_island()

func _on_SlimeBrain_slime_grew(mpos: Vector2):
    if mpos == $Space.player.map_position:
        GameState.set_water(GameState.water / 2)
        # We likely died in the middle of processing.  Keep state stable.
        $Space.call_deferred("warp_island")
