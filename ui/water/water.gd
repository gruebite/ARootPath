extends NinePatchRect

func change(to: int) -> void:
    $MarginContainer/HBoxContainer/Label.text = str(to)
