extends Node2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@export var floor_material := FloorType.Concrete
enum FloorType {Grass, Concrete, Water}

func _ready():
	for body in $Area2D.get_overlapping_bodies():
		_on_area_2d_body_entered(body)

func _on_area_2d_body_entered(body):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if body == player:
		player.stands_on = floor_material
	if body.is_in_group("enemy"):
		body.stands_on = floor_material
