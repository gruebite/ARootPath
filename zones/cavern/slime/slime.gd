extends Entity
class_name Slime

var tier := 0

func tier_up() -> void:
    tier = int(min(2, tier + 1))
    match tier:
        1:
            if zone.player.zone_position == zone_position:
                game.main.warp_island()
            region_rect = Rect2(340, 85, 16, 16)
        2: region_rect = Rect2(646, 187, 16, 16)

func bump() -> void:
    zone.kill_entity(self)
