extends Node2D

@export var linkedView: Node2D
@export var linkedFog: Node2D
var linkedDimOcc: Node2D
@export var high: bool
@export var release_force = 5000
@export var grabable: bool # for feture use case
@export var hide_light_occ: bool
@export var object_material: String = "Wood"

@onready var interaction_area: InteractionArea = $interaction_area
@onready var mouse_interaction_area = $MouseRangeInteraction
@onready var light_occ = $BlockSprite/LightOccluder2D
@onready var sounds = $Sounds


var health = 150
var standing_on = "grass"

var grabbed = false
var previous_player_position := Vector2.ZERO
var previous_player_rotation := 0.0
var relative_offset := Vector2.ZERO
var initial_angle_to_player := 0.0
var initial_mass

func _ready():
	interaction_area.interact = Callable(self,"_on_interact_toggle_light")
	interaction_area.second_interact = Callable(self,"_on_interact_grab")
	mouse_interaction_area.parent_interaction = interaction_area
	if hide_light_occ:
		interaction_area.main_action_name = "Turn off"
	interaction_area.second_action_name = "Grab"
	
	initial_mass = self.mass
	if high:
		$".".set_collision_layer_value(2, true)
		$".".set_collision_layer_value(3, false)
	else:
		$".".set_collision_layer_value(2, false)
		$".".set_collision_layer_value(3, true)
		light_occ.set_occluder_light_mask(2)
	if hide_light_occ:
		light_occ.occluder_light_mask = 0
		

func _process(_delta):
	if linkedView != null:
		linkedView.transform = self.transform
	if linkedFog != null:
		linkedFog.transform = self.transform
	if linkedDimOcc != null:
		linkedDimOcc.transform = self.transform
	
	if standing_on == "water":
		self.mass = initial_mass * 2
		$WaterSplash.emitting = true
	else:
		self.mass = initial_mass
		$WaterSplash.emitting = false
	
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	var dim_occ_viewport = get_tree().root.get_node_or_null("World/OtherDimension/DimensionsParserOccluders")
	var same_dim_viewport = get_tree().root.get_node_or_null("World/MainLevelViewport/SubViewport")
	var other_dim_viewport = get_tree().root.get_node_or_null("World/OtherDimension/ODVisibilityViewport") 
	var closest_distance = INF
	var closest_dimension_border = null
	
	for node in get_tree().get_nodes_in_group("dimension_split"):
		var dist = global_position.distance_to(node.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest_dimension_border = node
	
	var player_side = player.position.y
	var self_side = position.y
	if closest_dimension_border:
		player_side = player.position.y - closest_dimension_border.position.y
		self_side = position.y - closest_dimension_border.position.y
	#hide collision on close objects on the other side of the dim portal on the same dim as player
	if same_dim_viewport and same_dim_viewport.is_ancestor_of(self):
		if player_side * self_side > 0:
			if high:
				$".".set_collision_layer_value(2, true)
				$".".set_collision_layer_value(3, false)
			else:
				$".".set_collision_layer_value(3, true)
				$".".set_collision_layer_value(2, false)
		else:
			$".".set_collision_layer_value(2, false)
			$".".set_collision_layer_value(3, false)
			
	#hide dim occ on objects on the same side of the dim portal as player in the other dim
	if hide_light_occ:
		return
	if other_dim_viewport and other_dim_viewport.is_ancestor_of(self):
		if player_side * self_side > 0:
			light_occ.occluder_light_mask = 0
	else:
		if high:
			light_occ.occluder_light_mask = 257# 1 and 9
		else:
			light_occ.occluder_light_mask = 258# 2 and 9
	
	#hide dim occ on objects on the same side of the dim portal as player
	if dim_occ_viewport and dim_occ_viewport.is_ancestor_of(self):
		if player_side * self_side > 0:
			light_occ.occluder_light_mask = 257# 1 and 9
		else:
			light_occ.occluder_light_mask = 1



func _physics_process(delta):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if self.linear_velocity.length() > 5.0:
		play_sound("ObjectDrag", 200)
	else:
		stop_sound("ObjectDrag")
	
	if grabbed:
		var rotation_delta = player.top.rotation - previous_player_rotation
		relative_offset = (global_position - previous_player_position).rotated(rotation_delta)
		initial_angle_to_player += rotation_delta
		
		#new position calculation
		var target_position = player.global_position + relative_offset
		var position_error = target_position - global_position
		var kp = 130.0  # siła proporcjonalna
		var kd = 70.0   # siła tłumienia (prędkość)
		var desired_velocity = position_error / delta
		var force = ((desired_velocity - self.linear_velocity) * kd + position_error * kp) * self.mass
		$".".apply_central_force(force)
		
		#Rotacja
		rotation += rotation_delta
		
		var player_in_area := false
		for body in interaction_area.get_overlapping_bodies(): #realese grab if player isn't in the interaction zone
			if body == player:
				player_in_area = true
				break
		if !player_in_area:
			#_on_interact()
			_on_interact_grab()
		else:  #realese grab if rotation of player and object aren't matching
			var current_angle_to_player = (global_position - player.global_position).angle()
			var angle_diff = abs(wrapf(current_angle_to_player - initial_angle_to_player, -PI, PI))
			if angle_diff > 0.3:
				#_on_interact()
				_on_interact_grab()
	
	previous_player_position = player.global_position
	previous_player_rotation = player.top.rotation


func kill():
	if linkedView: linkedView.queue_free()
	if linkedFog: linkedFog.queue_free()
	queue_free()


func take_damage(attack: Attack):
	$".".apply_central_impulse(-attack.attack_direction * 500)
	health -= attack.attack_damage
	play_sound("ObjectHit", 200)
	if health <= 0:
		kill()


func play_sound(audio_name, noise_radius, material_related = true):
	#add alerting enemies within noise_radius
	var sound
	if material_related:
		sound = sounds.get_node_or_null(object_material+audio_name)
	else:
		sound = sounds.get_node_or_null(audio_name)
	if sound.playing == true and audio_name == "ObjectDrag":
		return
	sound.pitch_scale = randf_range(0.8, 1.2)
	if sound:
		sound.playing = true


var fading = false
func stop_sound(audio_name):
	var sound: AudioStreamPlayer2D = sounds.get_node_or_null(object_material + audio_name)
	if sound == null or !sound.playing or fading:
		return
	
	fading = true
	var tween = create_tween()
	tween.tween_property(sound, "volume_db", -80.0, 0.5)
	await tween.finished
	if sound.volume_db <= -79.0:
		sound.playing = false
		sound.volume_db = 0.0
		fading = false


func _on_interact_grab():
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if !grabbed:
		player.top.rotation = player.global_position.direction_to(global_position).angle() + PI/2
		previous_player_rotation = player.top.rotation
		grabbed = true
		interaction_area.second_action_name = "Let go"
		self.mass = initial_mass * 10 #changing mass for slowing player
		self.linear_velocity = Vector2(0,0)
		initial_angle_to_player = (global_position - player.global_position).angle()
		player.grab_object(self)
	else:
		self.mass = initial_mass
		interaction_area.second_action_name = "Grab"
		grabbed = false
		player.realese_object()
		
		var rotation_speed = player.top.rotation - previous_player_rotation
		var direction = (global_position - player.global_position).normalized()
		var force_direction = direction.rotated(sign(rotation_speed) * PI / 2)
		var force_strength = abs(rotation_speed) * release_force
		$".".apply_impulse(force_direction * force_strength)


func _on_interact_toggle_light():
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	var light_source = get_node_or_null("LightSource")
	var LinkedLight = linkedView.get_node_or_null("LightSource")
	var LinkedLightBulb = linkedView.get_node_or_null("Lightbulb")
	if light_source:
		if light_source.enabled == true:
			light_source.enabled = false
			LinkedLight.enabled = false
			light_source.hide()
			LinkedLight.hide()
			LinkedLightBulb.hide()
			$Lightbulb.hide()
			play_sound("Switch", 10, false)
			interaction_area.main_action_name = "Turn on"
		else:
			light_source.enabled = true
			LinkedLight.enabled = true
			light_source.show()
			LinkedLight.show()
			LinkedLightBulb.show()
			$Lightbulb.show()
			play_sound("Switch", 10, false)
			interaction_area.main_action_name = "Turn off"
