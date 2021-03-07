extends Node2D

const island_scene = preload("res://zones/island/island.tscn")

onready var zone: Node2D = $zone

func _ready():
    zone.add_child(island_scene.instance())
