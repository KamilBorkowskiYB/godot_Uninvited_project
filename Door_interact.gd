extends RigidBody2D

@onready var interaction_area: InteractionArea = $interaction_area
var transform_to
func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
	transform_to = self.transform
func _on_interact():
	self.transform = transform_to
