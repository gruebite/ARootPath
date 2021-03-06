extends Node2D
class_name TurnSystem

signal finished_turn()

enum {
    TURN_PLAYER,
    TURN_THINKERS,
}

var current_turn := TURN_PLAYER
var thinker_count := 0 setget _set_thinker_count

func reset() -> void:
    thinker_count = 0
    current_turn = TURN_PLAYER

func do_turn():
    assert(current_turn == TURN_PLAYER)
    thinker_count = len(get_tree().get_nodes_in_group("turn_taker"))
    get_tree().call_group("turn_taker", "take_turn")
    thinker_count += len(get_tree().get_nodes_in_group("thinker"))
    get_tree().call_group("thinker", "think")
    if thinker_count > 0:
        current_turn = TURN_THINKERS
    else:
        emit_signal("finished_turn")

func _set_thinker_count(value: int) -> void:
    assert(current_turn == TURN_THINKERS)
    thinker_count = value
    if thinker_count == 0:
        current_turn = TURN_PLAYER
        emit_signal("finished_turn")

func _on_SlimeBrain_slime_finished_thinking():
    self.thinker_count -= 1
