extends Node
class_name Game

var rng := RandomNumberGenerator.new()

var main: Main = null

func _ready() -> void:
    rng.randomize()
