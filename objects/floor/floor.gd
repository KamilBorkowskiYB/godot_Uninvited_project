extends Node2D


@export var stands_on:String = "grass"#check if exists same value in player sricp step function
func _ready():
	for area in $Area2D.get_overlapping_bodies():
		_on_area_2d_area_entered(area)

func _on_area_2d_area_entered(area):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if area.get_parent() == player:
		player.standing_on = stands_on
	if area.get_parent().is_in_group("enemy"):
		area.get_parent().standing_on = stands_on

