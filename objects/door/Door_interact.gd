extends RigidBody2D

@onready var interaction_area: InteractionArea = $interaction_area
var transform_to
var isClosed = true
var health = 100
signal destroyed
func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
	transform_to = self.transform

func _process(delta):
	if $".".mass == 1.0:
		$interaction_area.action_name = "Close"
	else:
		$interaction_area.action_name = "Open"
func _on_interact():
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if(isClosed):
		isClosed = false
		$".".mass = 1.0
		if(player.global_position.y > self.global_position.y):
			apply_central_impulse(Vector2(0,-450000))
		else:
			apply_central_impulse(Vector2(0,450000))
		if(player.global_position.x > self.global_position.x):
			apply_central_impulse(Vector2(-450000,0))
		else:
			apply_central_impulse(Vector2(450000,0))
	else:
		isClosed = true
		$".".set_linear_velocity(Vector2.ZERO)
		$".".set_angular_velocity(0)
		await get_tree().create_timer(0.01).timeout #huh why
		self.transform = transform_to
		$".".mass = 1000.0
func kill(attack: Attack):
	if isClosed:
		isClosed = false
		$".".mass = 1.0
		apply_central_impulse(-attack.attack_direction * 500000)
	else:#huh why
		apply_central_impulse(-attack.attack_direction * 500)
	health -= attack.attack_damage
	if health <= 0:
		destroyed.emit()
		get_parent().queue_free()
