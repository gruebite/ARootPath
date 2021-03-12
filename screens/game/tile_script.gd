tool
extends TileSet

func _is_tile_bound(id, neighbour_id):
    return neighbour_id == Tile.WATER and id == Tile.GROUND
    #return neighbour_id in get_tiles_ids()
