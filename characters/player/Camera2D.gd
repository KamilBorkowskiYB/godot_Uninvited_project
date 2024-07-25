extends Camera2D

@export var vision_camera: Camera2D #viewPorty
@export var fog_camera: Camera2D #viewPorty

func _process(_delta):
	if vision_camera != null:
		vision_camera.position = self.position
		vision_camera.offset = self.offset
	if fog_camera != null:
		fog_camera.position = self.position
		fog_camera.offset = self.offset
