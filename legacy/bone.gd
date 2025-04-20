@tool
extends Bone2D

@export var intendent_scale = 1.0

func _process(delta):
	if get_parent() is Skeleton2D:
		scale = Vector2(1.0, intendent_scale)
	else:
		#scale = Vector2.ONE / get_parent().intendent_scale * intendent_scale 
		scale = Vector2(1.0, intendent_scale / get_parent().intendent_scale)
		
