extends Control

func change(to: int) -> void:
    $HBoxContainer/Label.text = str(to)
