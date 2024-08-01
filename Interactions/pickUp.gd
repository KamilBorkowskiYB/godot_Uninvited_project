extends CPUParticles2D

@onready var interaction_area: InteractionArea = $InteractionArea
@export var item_name = "None"
signal item_picked_up()

func _ready():
	interaction_area.interact = Callable(self,"_on_interact")


func _on_interact():
	item_picked_up.emit()
	queue_free()
