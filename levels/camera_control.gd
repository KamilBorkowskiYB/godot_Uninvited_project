extends Node2D
#should be added to parent of player and camera
var DEAD_ZONE = 200
var max_view_distance = 600
var shake_amount = 0
var shake_timer = 0

func _process(_delta):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var mouse_position = get_global_mouse_position()
	var player_position = player.global_position
	var distance = player_position.distance_to(mouse_position)
	var target_position = player_position

	if distance > DEAD_ZONE:
		var direction = (mouse_position - player_position).normalized()
		var clamped_distance = min(distance, max_view_distance)
		target_position = player_position + direction * (clamped_distance - DEAD_ZONE) * 0.5
	
	$PlayerCamera.global_position = target_position
	
	if shake_timer > 0:
		shake_timer -= _delta
		$PlayerCamera.offset = Vector2(randi_range(-shake_amount, shake_amount), randi_range(-shake_amount, shake_amount))
	else:
		$PlayerCamera.offset = Vector2.ZERO

func start_shake(amount, duration):
	shake_amount = amount
	shake_timer = duration
