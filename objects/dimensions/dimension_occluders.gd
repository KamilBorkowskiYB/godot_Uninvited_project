extends Node2D

@export var vertical:bool = true
@export var vis_from_right_or_bottom:bool = true


func _process(_delta):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if vertical:
		if vis_from_right_or_bottom:
			if player.position.x - self.position.x < 5:
				$LightOccluder2D.occluder_light_mask = 1
			else:
				$LightOccluder2D.occluder_light_mask = 257
		else:
			if player.position.x - self.position.x > 5:
				$LightOccluder2D.occluder_light_mask = 1
			else:
				$LightOccluder2D.occluder_light_mask = 257
	else:
		if vis_from_right_or_bottom:
			if player.position.y - self.position.y < 5:
				$LightOccluder2D.occluder_light_mask = 1
			else:
				$LightOccluder2D.occluder_light_mask = 257
		else:
			if player.position.y - self.position.y > 5:
				$LightOccluder2D.occluder_light_mask = 1
			else:
				$LightOccluder2D.occluder_light_mask = 257
