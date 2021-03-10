extends Node
class_name Game

# Animating count.  0 when we're not animating.
var animating := 0

var rng := RandomNumberGenerator.new()

var main: Main = null

func _ready() -> void:
    rng.randomize()
