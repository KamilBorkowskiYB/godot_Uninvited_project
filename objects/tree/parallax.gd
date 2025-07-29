extends Sprite2D

enum ParallaxPreset { Custom, Slow, Medium, Fast }
@export var parallax_preset: ParallaxPreset = ParallaxPreset.Medium
@export var custom_parallax_strength: Vector2 = Vector2(0.03, 0.03)
@export var parralax_on: bool = false
@onready var base_position := global_position

func get_strength() -> Vector2:
	match parallax_preset:
		ParallaxPreset.Slow:
			return Vector2(0.03, 0.03)
		ParallaxPreset.Medium:
			return Vector2(0.05, 0.05)
		ParallaxPreset.Fast:
			return Vector2(0.06, 0.06)
		_:
			return custom_parallax_strength

func _process(_delta):
	var camera := get_viewport().get_camera_2d()
	if camera and parralax_on:
		var camera_offset = (camera.global_position - base_position) * get_strength()
		global_position = base_position - camera_offset
