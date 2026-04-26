extends Node2D

signal swap_dimensions

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		call_deferred("emit_swap")

func emit_swap():
	swap_dimensions.emit()
