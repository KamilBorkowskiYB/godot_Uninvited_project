extends Node2D

@export var linkedView: Node2D
@export var linkedFog: Node2D
@export var high: bool
@export var release_force = 5000
@export var grabable: bool # for feture use case

@onready var interaction_area: InteractionArea = $interaction_area
@onready var mouse_interaction_area = $MouseRangeInteraction

var health = 150
var standing_on = "grass"

var grabbed = false
var previous_player_position := Vector2.ZERO
var previous_player_rotation := 0.0
var relative_offset := Vector2.ZERO
var initial_angle_to_player := 0.0
var initial_mass

func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
	mouse_interaction_area.parent_interaction = interaction_area
	
	initial_mass = self.mass
	if high:
		$".".set_collision_layer_value(2, true)
		$".".set_collision_layer_value(3, false)
	else:
		$".".set_collision_layer_value(2, false)
		$".".set_collision_layer_value(3, true)
		$BlockSprite/LightOccluder2D.set_occluder_light_mask(2)

func _process(_delta):
	if linkedView != null:
		linkedView.transform = self.transform
	if linkedFog != null:
		linkedFog.transform = self.transform
	
	if standing_on == "water":
		self.mass = initial_mass * 2
		$WaterSplash.emitting = true
	else:
		self.mass = initial_mass
		$WaterSplash.emitting = false


func _physics_process(delta):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
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
			_on_interact()
		else:  #realese grab if rotation of player and object aren't matching
			var current_angle_to_player = (global_position - player.global_position).angle()
			var angle_diff = abs(wrapf(current_angle_to_player - initial_angle_to_player, -PI, PI))
			if angle_diff > 0.3:
				_on_interact()
	
	previous_player_position = player.global_position
	previous_player_rotation = player.top.rotation


func kill(attack: Attack):
	$".".apply_central_impulse(-attack.attack_direction * 500)
	health -= attack.attack_damage
	if health <= 0:
		linkedView.queue_free()
		linkedFog.queue_free()
		queue_free()

func _on_interact():
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if !grabbed:
		player.top.rotation = player.global_position.direction_to(global_position).angle() + PI/2
		previous_player_rotation = player.top.rotation
		grabbed = true
		interaction_area.action_name = "Let go"
		self.mass = initial_mass * 10 #changing mass for slowing player
		self.linear_velocity = Vector2(0,0)
		initial_angle_to_player = (global_position - player.global_position).angle()
		player.grab_object(self)
	else:
		self.mass = initial_mass
		interaction_area.action_name = "Grab"
		grabbed = false
		player.realese_object()
		
		var rotation_speed = player.top.rotation - previous_player_rotation
		var direction = (global_position - player.global_position).normalized()
		var force_direction = direction.rotated(sign(rotation_speed) * PI / 2)
		var force_strength = abs(rotation_speed) * release_force
		$".".apply_impulse(force_direction * force_strength)
