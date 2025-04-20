extends Area2D
#SHOULD BE CALLED IN ANIMATION INSTEAD OF EVERY FRAME
var tilemap: TileMap
var found_tile = false

func _process(_delta):
	if is_instance_valid(tilemap):
		var area_position = tilemap.to_local(global_position)
		var map_position = tilemap.local_to_map(area_position)
		for i in range(3, -1, -1): #itereting throu all walkable floors and breaking on top one
			var tile_id = tilemap.get_cell_tile_data(i, map_position)
			if tile_id and tile_id.get_custom_data("footsteps"):
				found_tile = true
				get_parent().standing_on = tile_id.get_custom_data("footsteps")
				break
	if !found_tile:
		for area in get_overlapping_areas():
			get_parent().standing_on = area.get_parent().stands_on
	found_tile = false


