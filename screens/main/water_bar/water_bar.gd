extends Control

const SPEED := 0.01

onready var amount := $container/text/amount
onready var bar := $container/bar

var current_water := 0
var target_water := 0

var timer := 0.0

func _ready() -> void:
    target_water = 42

func _process(delta: float) -> void:
    if current_water == target_water:
        return
    timer += delta
    if timer >= SPEED:
        timer = 0
        var dir := int(sign(target_water - current_water))
        current_water += dir
        amount.text = str(current_water)
        bar.update()
