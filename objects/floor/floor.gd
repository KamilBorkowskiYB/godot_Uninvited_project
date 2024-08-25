extends Node2D

@export var floor_material := FloorType.Concrete #should be same as in player script
enum FloorType {Grass, Concrete, Water}

func _ready():
#	for body in $Area2D.get_overlapping_bodies():
#		_on_area_2d_body_entered(body)
	for area in $Area2D.get_overlapping_bodies():
		_on_area_2d_area_entered(area)

func _on_area_2d_area_entered(area):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if area.get_parent() == player:
		player.stands_on = floor_material
	if area.get_parent().is_in_group("enemy"):
		area.get_parent().stands_on = floor_material

#func _on_area_2d_body_entered(body):#not used
#	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
#	if body == player:
#		player.stands_on = floor_material
#	if body.is_in_group("enemy"):
#		body.stands_on = floor_material
