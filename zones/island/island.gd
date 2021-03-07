extends Node2D

const WIDTH := 30
const HEIGHT := 30

var walker := Walker.new()

func _ready():
    generate()

func generate() -> void:
    walker.start(WIDTH, HEIGHT)
    walker.goto(WIDTH / 2, HEIGHT / 2)
    walker.mark_circle(8)
    walker.commit()
    var loops := 0
    var subloops := 0
    while walker.percent_opened() < 0.6:
        loops += 1
        walker.remember()
        walker.goto_random_closed()
        while not walker.on_opened():
            subloops += 1
            walker.step_weighted_last(0.55)
            walker.mark_plus()
        walker.commit()
        walker.forget()
    walker.debug_print()
    print(loops, " ", subloops)
