extends Area2D

var tilemap: TileMap

func _on_Area2D_body_entered(body):
	if body is TileMap:
		print("Contact")
		if tilemap:
			var area_position = tilemap.to_local(global_position)
			var map_position = tilemap.local_to_map(area_position)
			print(map_position)
			for i in range(3, -1, -1):
				var tile_id = tilemap.get_cell_tile_data(i, map_position)
				if tile_id:
					print(tile_id.get_custom_data("footsteps"))
					break
