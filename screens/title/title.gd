extends Node2D

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        $AnimationPlayer.play("start")
        yield($AnimationPlayer, "animation_finished")
        get_tree().change_scene("res://screens/game/game.tscn")

