extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

@export var move_speed = 100
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

var dead = false

func _physics_process(_delta):
	if dead:
		return
	var dir_to_player = global_position.direction_to(player.global_position)
	velocity = move_speed * dir_to_player
	move_and_slide()
	
	global_rotation = dir_to_player.angle() + PI/2.0
	
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
		player.kill()
		
func kill():
	if dead:
		return
	dead = true
	$DeathSound.play()
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CollisionShape2D.disabled = true
	z_index = -1
	
	
