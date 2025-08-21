extends RigidBody2D

@onready var interaction_area: InteractionArea = $interaction_area
@onready var mouse_interaction_area = $MouseRangeInteraction
@onready var potential_double_doors = get_parent().get_parent()

var transform_to
var isClosed = true
var health = 100
signal destroyed
func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
	mouse_interaction_area.parent_interaction = interaction_area
	
	transform_to = self.transform

func _process(_delta):
	if freeze == false:
		interaction_area.action_name = "Close"
	else:
		interaction_area.action_name = "Open"


func _on_interact():
	if(isClosed):
		if potential_double_doors.has_method("open_doors"):
			potential_double_doors.open_doors()
		else:
			open()
	else:
		if potential_double_doors.has_method("close_doors"):
			potential_double_doors.close_doors()
		else:
			close()


func kill(attack: Attack):
	if isClosed:
		isClosed = false
		freeze = false
	if potential_double_doors.has_method("doors_shot"):
		potential_double_doors.doors_shot(self, attack.attack_direction)
	trigger_linked_event()
	apply_central_impulse(-attack.attack_direction * 500)
	health -= attack.attack_damage
	if health <= 0:
		destroyed.emit()
		get_parent().queue_free()


func open():
	trigger_linked_event()
	
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	isClosed = false
	freeze = false
	if(player.global_position.y > self.global_position.y):
		apply_central_impulse(Vector2(0,-450))
	else:
		apply_central_impulse(Vector2(0,450))
	if(player.global_position.x > self.global_position.x):
		apply_central_impulse(Vector2(-450,0))
	else:
		apply_central_impulse(Vector2(450,0))


func close():
	isClosed = true
	set_linear_velocity(Vector2.ZERO)
	set_angular_velocity(0)
	self.transform = transform_to
	freeze = true
	
	for body in interaction_area.get_overlapping_bodies(): #apply impulse to push object out of the door
		if body is RigidBody2D:
			body.apply_impulse(Vector2.ZERO, Vector2(1,1))

func trigger_linked_event():
	var parent = get_parent() #Trigger an event
	if parent.hidden_area and is_instance_valid(parent.hidden_area):
		var trigger = parent.hidden_area.get_node_or_null("TriggerEvent")
		if trigger:
			trigger.trigger_event()
