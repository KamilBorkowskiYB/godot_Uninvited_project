extends Node2D

@export var linkedView: Node2D
@export var linkedFog: Node2D
@export var high: bool
@export var grabable: bool # for feture use case

@onready var interaction_area: InteractionArea = $interaction_area

var health = 150
var standing_on = "grass"
var move_direction = Vector2(0,0) # for water surface effect

var grabbed = false
var previous_player_position := Vector2.ZERO
var initial_mass
@export var max_to_player_distance = 130


func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
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
		self.mass = initial_mass * 10
		$WaterSplash.emitting = true
	else:
		self.mass = initial_mass
		$WaterSplash.emitting = false

func _physics_process(delta):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	var player_movement = player.global_position - previous_player_position
	
	if grabbed:
		global_position += player_movement
		
		if global_position.distance_to(player.global_position) > max_to_player_distance:
			_on_interact()
	
	previous_player_position = player.global_position


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
		grabbed = true
		interaction_area.action_name = "Let go"
		self.mass = 10
		self.linear_velocity = Vector2(0,0)
		player.grab_object(self)
	else:
		self.mass = 1
		interaction_area.action_name = "Grab"
		grabbed = false
		player.realese_object()
