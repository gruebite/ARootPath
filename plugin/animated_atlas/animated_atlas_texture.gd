extends AtlasTexture
class_name AnimatedAtlasTexture

export(int, 1, 100) var h_frames := 1
export(int, 1, 100) var v_frames := 1
export var fps := 10.0

func _init() -> void:
  var err = VisualServer.connect("frame_pre_draw", self, "_update")
  assert(err == OK)

func _update() -> void:
    if atlas:
        var img := atlas.get_data()
        var size = img.get_size()
        var frame_size = size / Vector2(h_frames, v_frames)
        var frame = int(int(OS.get_ticks_msec() / (1000.0 / fps)) % (h_frames * v_frames))
        var frame_pos = Vector2(frame % h_frames, floor(float(frame) / h_frames))
        region = Rect2(frame_size * frame_pos, frame_size)
