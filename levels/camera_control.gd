extends Node2D
#should be added to parent of player and camera
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
var DEAD_ZONE = 160
var max_view_distance = 600

func _process(_delta):
	var mouse_position = get_global_mouse_position()
	var player_position = player.global_position
	var distance = player_position.distance_to(mouse_position)
	var target_position = player_position

	if distance > DEAD_ZONE:
		var direction = (mouse_position - player_position).normalized()
		var clamped_distance = min(distance, max_view_distance)
		target_position = player_position + direction * (clamped_distance - DEAD_ZONE) * 0.5
	
	$PlayerCamera.global_position = target_position
