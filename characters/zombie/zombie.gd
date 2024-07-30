extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

@export var move_speed = 100
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var animation_player = $AnimationPlayer
var dead = false
@export var push_force = 10.0

func _ready():
	animation_player.play("walk")
func _physics_process(_delta):
	if dead:
		return
	var dir_to_player = global_position.direction_to(player.global_position)
	velocity = move_speed * dir_to_player
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	
	global_rotation = dir_to_player.angle() + PI/2.0
	
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
		player.kill()
		
func kill(attack: Attack):
	if dead:
		return
	dead = true
	$DeathSound.play()
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$Graphics/Legs.hide()
	$CollisionShape2D.disabled = true
	z_index = -1
	
	
