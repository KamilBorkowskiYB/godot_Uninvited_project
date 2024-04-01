extends RigidBody2D

@onready var interaction_area: InteractionArea = $interaction_area
var transform_to
var isClosed = true
func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
	transform_to = self.transform
func _on_interact():
	if(isClosed):
		isClosed = false
		$".".mass = 1.0
		apply_central_impulse(Vector2(0,-300000))
	else:
		self.transform = transform_to
		isClosed = true
		$".".mass = 1000.0
