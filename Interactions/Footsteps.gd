extends Area2D

var tilemap: TileMap

func _ready():
	for area in get_overlapping_bodies():
		_on_area_entered(area)

func _on_Area2D_body_entered(body):
	if body is TileMap:
		if tilemap:
			var area_position = tilemap.to_local(global_position)
			var map_position = tilemap.local_to_map(area_position)
			for i in range(3, -1, -1): #itereting throu all walkable floors and breaking on top one
				var tile_id = tilemap.get_cell_tile_data(i, map_position)
				if tile_id and tile_id.get_custom_data("footsteps"):
					get_parent().standing_on = tile_id.get_custom_data("footsteps")
					break

func _on_area_entered(area):
	get_parent().standing_on = area.get_parent().stands_on

