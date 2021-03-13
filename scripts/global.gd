extends Node

var space: Space

var rng := RandomNumberGenerator.new()

var _muted := false

func _ready() -> void:
    rng.randomize()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_M:
            var db := 0
            _muted = not _muted
            if _muted:
                db = -80
            AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
            AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
