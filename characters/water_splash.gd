extends CPUParticles2D
var parent_node
@export var offset = 20

func _ready():
	parent_node = get_parent()

func _process(delta):
	position = Vector2(0,0) + parent_node.move_direction * offset
