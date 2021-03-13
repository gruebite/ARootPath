extends Node2D

var faded_in := false

func _ready() -> void:
    $CanvasLayer/Control/VBoxContainer/DelveCount.text = str(GameState.delve_count)

func _unhandled_input(event: InputEvent) -> void:
    if not faded_in: return
    if event.is_action_pressed("ui_accept"):
        get_tree().change_scene("res://screens/title/title.tscn")



func _on_AnimationPlayer_animation_finished(anim_name):
    faded_in = true
