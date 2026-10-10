@tool
extends Node2D

@export var main_scene_level: PackedScene:
	set(value):
		main_scene_level = value
		if Engine.is_editor_hint():
			replace_level_in_scene()


func replace_level_in_scene():
	#pass
	var icon = load("res://icon.svg")
	var sprite := Sprite2D.new()
	sprite.name = "TestIcon"
	sprite.texture = icon
	self.add_child(sprite)
	sprite.owner = get_tree().edited_scene_root
