extends Area2D
class_name InteractionArea

@export var main_action_name: String = "null"
@export var second_action_name: String = "null"
var interact: Callable = func():
	pass
var second_interact: Callable = func():
	pass

func _on_body_entered(_body):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if _body == player:
		InteractionManager.register_area(self)

func _on_body_exited(_body):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if _body == player:
		InteractionManager.unregister_area(self)
