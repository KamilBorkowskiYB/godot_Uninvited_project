extends Camera2D

@export var vision_camera: Camera2D #viewPorty
@export var fog_camera: Camera2D #viewPorty

@export var dim_split_camera: Camera2D #viewPorty
@export var dim_split_camera_occluders: Camera2D #viewPorty
@export var od_main_camera: Camera2D #viewPorty
@export var od_fog_camera: Camera2D #viewPorty
@export var od_vision_camera: Camera2D #viewPorty

func _process(_delta):
	if vision_camera != null:
		vision_camera.position = self.position
		vision_camera.offset = self.offset
	if fog_camera != null:
		fog_camera.position = self.position
		fog_camera.offset = self.offset
	if dim_split_camera != null:
		dim_split_camera.position = self.position
		dim_split_camera.offset = self.offset
	if dim_split_camera_occluders != null:
		dim_split_camera_occluders.position = self.position
		dim_split_camera_occluders.offset = self.offset
	if od_main_camera != null:
		od_main_camera.position = self.position
		od_main_camera.offset = self.offset
	if od_fog_camera != null:
		od_fog_camera.position = self.position
		od_fog_camera.offset = self.offset
	if od_vision_camera != null:
		od_vision_camera.position = self.position
		od_vision_camera.offset = self.offset
