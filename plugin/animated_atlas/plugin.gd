tool
extends EditorPlugin

var resource: AnimatedAtlasTexture

func _enter_tree() -> void:
    VisualServer.connect("frame_pre_draw", self, "_update")

func _exit_tree() -> void:
    VisualServer.disconnect("frame_pre_draw", self, "_update")

func handles(object: Object) -> bool:
    if object is AnimatedAtlasTexture:
        resource = object as AnimatedAtlasTexture
    return object is AnimatedAtlasTexture

func _update() -> void:
    if resource is AnimatedAtlasTexture:
        if resource.atlas:
            var img := resource.atlas.get_data()
            var size = img.get_size()
            var frame_size = size / Vector2(resource.h_frames, resource.v_frames)
            var frame = int(int(OS.get_ticks_msec() / (1000.0 / resource.fps)) % (resource.h_frames * resource.v_frames))
            var frame_pos = Vector2(frame % resource.h_frames, floor(float(frame) / resource.h_frames))
            resource.region = Rect2(frame_size * frame_pos, frame_size)
