extends PointLight2D

func _process(delta):
	var pos = get_global_mouse_position()
	#var pos = get_local_mouse_position()
	#var pos = $"../../MainLevelViewport/SubViewport".get_mouse_position()
	
	position = pos
