extends Area2D

signal reveal_area

func _on_body_entered(body):
	if body.is_in_group("player"):
		var parent_name = get_parent().name
		reveal_area.emit(parent_name)
