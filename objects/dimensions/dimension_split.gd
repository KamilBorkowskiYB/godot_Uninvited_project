extends Node2D

signal swap_dimensions

var swap_distance := 17.0
var occluder_offset := 15.0
var entered_from_top = false
var border_width = 135.0
var occluder_speed := 240.0
var min_distance := 5.0
@onready var lightOccluder = $LightOccluder2D
@export var lightOccRestPos = 1296.0
@onready var area = $Area2D


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		entered_from_top = body.global_position.y < area.global_position.y


func _process(delta):
	var overlapping_bodies = area.get_overlapping_bodies()
	var player = get_tree().get_first_node_in_group("player")
	
	#moving dimension border for better visibility
	var target_y = lightOccRestPos
	if abs(player.global_position.y - lightOccRestPos) <= swap_distance:
		if abs(player.global_position.x - lightOccluder.global_position.x) < border_width:
			if player.global_position.y < lightOccRestPos:
				target_y = lightOccRestPos + occluder_offset
				target_y = max(target_y, player.global_position.y + min_distance)
			else:
				target_y = lightOccRestPos - occluder_offset
				target_y = min(target_y, player.global_position.y - min_distance)
	else:
		target_y = lightOccRestPos
	lightOccluder.global_position.y = move_toward(lightOccluder.global_position.y, target_y, occluder_speed * delta)
	
	#swaping dimensions
	for body in overlapping_bodies:
		if body.is_in_group("player"):
			var center_y = area.global_position.y
			#enter from top
			if entered_from_top:
				if body.global_position.y > center_y:
					call_deferred("emit_swap")
			#enter from bottom
			else:
				if body.global_position.y < center_y:
					call_deferred("emit_swap")


func emit_swap():
	swap_dimensions.emit()
