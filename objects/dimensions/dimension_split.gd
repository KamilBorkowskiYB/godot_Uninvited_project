extends Node2D

signal swap_dimensions

# Stores which side each body entered from
var entered_from := {}

func _on_area_2d_body_entered(body):
	if !body.is_in_group("player"):
		return
	
	var area = $Area2D
	var center_y = area.global_position.y

	if body.global_position.y < center_y:
		entered_from[body] = "top"
	else:
		entered_from[body] = "bottom"


func _on_area_2d_body_exited(body):
	if !body.is_in_group("player"):
		return
	
	if !entered_from.has(body):
		return
	
	var area = $Area2D
	var center_y = area.global_position.y
	
	var exit_side = ""
	if body.global_position.y < center_y:
		exit_side = "top"
	else:
		exit_side = "bottom"
	
	var enter_side = entered_from[body]
	
	# only swap if exited opposite side
	if enter_side != exit_side:
		call_deferred("emit_swap")
	
	entered_from.erase(body)


func emit_swap():
	swap_dimensions.emit()
