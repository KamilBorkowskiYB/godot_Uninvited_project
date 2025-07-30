extends RigidBody2D

@onready var interaction_area: InteractionArea = $interaction_area
var transform_to
var isClosed = true
var health = 100
signal destroyed
func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
	transform_to = self.transform

func _process(_delta):
	if freeze == false:
		interaction_area.action_name = "Close"
	else:
		interaction_area.action_name = "Open"


func _on_interact():
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if(isClosed):
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
	else:
		isClosed = true
		set_linear_velocity(Vector2.ZERO)
		set_angular_velocity(0)
		self.transform = transform_to
		freeze = true
		
		for body in interaction_area.get_overlapping_bodies(): #apply impulse to push object out of the door
			if body is RigidBody2D:
				body.apply_impulse(Vector2.ZERO, Vector2(1,1))



func kill(attack: Attack):
	if isClosed:
		isClosed = false
		freeze = false
	apply_central_impulse(-attack.attack_direction * 500)
	health -= attack.attack_damage
	if health <= 0:
		destroyed.emit()
		get_parent().queue_free()
