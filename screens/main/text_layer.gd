extends CanvasLayer

const SCROLL_TIME := 2.0

onready var text_container := $text_container
onready var text_label := $text_container/label

var running := false

var text_array := []
var confirm_callback: FuncRef = null

var text_index := 0
var text_timer := 0.0

func _ready():
    pass

func _process(delta: float):
    if not running: return
    
    text_timer = min(text_timer + delta, SCROLL_TIME)
    var p := text_timer / SCROLL_TIME
    var line: String = text_array[text_index]
    text_label.text = line.substr(0, int(p * len(line)))

func _input(event: InputEvent):
    if not running: return
    
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
        if text_timer >= SCROLL_TIME:
            text_timer = 0
            text_index += 1
        else:
            text_timer = SCROLL_TIME
        
        if text_index >= len(text_array):
            running = false
            text_container.hide()
            if confirm_callback:
                confirm_callback.call_func()
    get_tree().set_input_as_handled()
        

func show_with(texts: Array, confirm: FuncRef=null) -> void:
    text_array = texts
    confirm_callback = confirm
    
    text_index = 0
    text_timer = 0
    
    running = true

    text_container.show()
