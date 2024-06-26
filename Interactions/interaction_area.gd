extends Area2D
class_name InteractionArea

@export var action_name: String = "Open/Close"
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
var interact: Callable = func():
	pass

func _mouse_in():
	InteractionManager.register_in_mouse_range(self)

func _mouse_out():
	InteractionManager.unregister_in_mouse_range(self)

func _on_body_entered(_body):
	if _body == player:
		InteractionManager.register_area(self)

func _on_body_exited(_body):
	if _body == player:
		InteractionManager.unregister_area(self)
