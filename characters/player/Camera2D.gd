extends Camera2D

# -------- Viewport cameras --------
@export var vision_camera: Camera2D
@export var fog_camera: Camera2D

@export var dim_split_camera: Camera2D
@export var dim_split_camera_occluders: Camera2D

@export var od_main_camera: Camera2D
@export var od_fog_camera: Camera2D
@export var od_vision_camera: Camera2D

# -------- Camera movement --------
@export var dead_zone := 200.0
@export var max_view_distance := 600.0

# -------- Shake --------
var shake_amount := 0.0
var shake_timer := 0.0

# -------- Shader tracking --------
var list_of_materials:Array = []
var position_array:Array[Vector2] = [
	Vector2.ZERO,
	Vector2.ZERO
]
const MAX_POSITIONS := 2


func _ready():
	position_array.resize(MAX_POSITIONS)
	var transparent_nodes = get_tree().get_nodes_in_group("Transparent")
	
	for n in transparent_nodes:
		var mat:ShaderMaterial = n.material
		if mat:
			list_of_materials.append(mat)


func _process(delta):
	update_camera_follow(delta)
	connect_other_viewports_cameras()
	update_shader_positions()


func update_camera_follow(delta):
	var player:CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var mouse_position = get_global_mouse_position()
	var player_position = player.global_position
	var distance = player_position.distance_to(mouse_position)
	var screen_middle = get_viewport().get_visible_rect().size / 2
	var target_position = player_position
	var screen_position = screen_middle
	
	if distance > dead_zone:
		var direction = (mouse_position - player_position).normalized()
		var clamped_distance = min(distance, max_view_distance)
		target_position = player_position + direction * (clamped_distance - dead_zone) * 0.5
		screen_position = screen_middle - direction * (clamped_distance - dead_zone) * 0.5
	
	global_position = target_position.round()
	player.aim_assist.global_position = screen_position
	
	if shake_timer > 0:
		shake_timer -= delta
		offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
	else:
		offset = Vector2.ZERO


func connect_other_viewports_cameras():
	var cams = [
		vision_camera,
		fog_camera,
		dim_split_camera,
		dim_split_camera_occluders,
		od_main_camera,
		od_fog_camera,
		od_vision_camera
	]
	
	for cam in cams:
		if cam:
			cam.position = position
			cam.offset = offset


func update_shader_positions():
	var screen_middle = get_viewport().get_visible_rect().size / 2
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var mouse_position = get_global_mouse_position()
	var player_position = player.global_position
	var distance = player_position.distance_to(mouse_position)
	var screen_position = screen_middle
	
	if distance > dead_zone:
		var direction = (mouse_position - player_position).normalized()
		var clamped_distance = min(distance, max_view_distance)
		screen_position = screen_middle - direction * (clamped_distance - dead_zone) * 0.5
		
	var new_position = get_viewport().get_mouse_position()
	position_array.insert(0,new_position)
	position_array.insert(1,screen_position)
	
	while position_array.size() > MAX_POSITIONS:
		position_array.pop_back()
	
	for m in list_of_materials:
		m.set_shader_parameter(
			"CircleCentres",
			position_array
		)
		
		m.set_shader_parameter(
			"NumCircleCentres",
			position_array.size()
		)


func start_shake(amount,duration):
	shake_amount = amount
	shake_timer = duration
