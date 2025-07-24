extends Node2D

@export var stands_on:String = "grass"#check if exists same value in player sricp step function

# At this state all walkable surfaces are managed by tilemaps
# But footsteps are set using this script if no tiles are detected
# So current use is for water, that is not managed by tilemaps
# Can be used in the future by no timeset elements

func _ready():
	if stands_on == "water":
		var sprite_scale_x = scale.x
		var sprite_scale_y = scale.y
		var shader = $FloorSprite.material
		
		var offset = 10 #Shader always streches  by default 10 times
		if shader is ShaderMaterial:
			shader.set_shader_parameter("sprite_scale", Vector2(sprite_scale_x/offset, sprite_scale_y/offset))
