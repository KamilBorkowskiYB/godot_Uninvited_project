extends Area2D

var parent_interaction: InteractionArea

func _on_mouse_entered():
	InteractionManager.register_in_mouse_range(parent_interaction)


func _on_mouse_exited():
	InteractionManager.unregister_in_mouse_range(parent_interaction)
