extends Control

func change(to: int) -> void:
    $NinePatch/MarginContainer/HBoxContainer/Label.text = str(to)
