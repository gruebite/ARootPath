extends Node2D

const LEVELS = [
    50, 70, 100, 141, 173
]

var walker := Walker.new()

func _ready():
    carve()

func carve(level: int=1) -> void:
    walker.start(LEVELS[level], LEVELS[level] / 3)
    walker.goto(LEVELS[level] / 2, LEVELS[level] / 6)
    walker.mark_plus()
    walker.commit()
    var loops := 0
    var subloops := 0
    while walker.percent_opened() < 0.6:
        loops += 1
        walker.goto_random_opened()
        walker.remember()
        walker.goto_random_closed()
        while not walker.on_opened():
            subloops += 1
            walker.step_weighted_last(0.8)
            walker.mark_plus()
        walker.commit()
        walker.forget()
    walker.debug_print()
    print(loops, " ", subloops)
