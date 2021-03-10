extends Control
class_name MessageBox

const SCROLL_TIME := 2.0

onready var text_label := $box/margin/label

var texts := []
var yes: FuncRef = null
var no: FuncRef = null

var text_index := 0
var text_timer := 0.0

func _ready() -> void:
    grab_focus()

func _process(delta: float) -> void:
    text_timer = min(text_timer + delta, SCROLL_TIME)
    var p := text_timer / SCROLL_TIME
    var line: String = texts[text_index]
    text_label.text = line.substr(0, int(p * len(line)))

func _gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
        if text_timer >= SCROLL_TIME:
            text_timer = 0
            text_index += 1
        else:
            text_timer = SCROLL_TIME
        
        if text_index >= len(texts):
            queue_free()
            if yes:
                yes.call_func()
    accept_event()
