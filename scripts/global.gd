extends Node

var space: Space

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
