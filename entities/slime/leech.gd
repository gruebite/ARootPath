extends Entity

signal finished_thinking()

func think() -> void:
    emit_signal("finished_thinking")

func damage() -> void:
    emit_signal("died")
