extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

@export var move_speed = 100
@onready var animation_player = $AnimationPlayer
var dead = false
@export var push_force = 10.0
var move_direction = Vector2(0,0)
var standing_on :String = "grass"
var floor_move_speed_debuff = 1.0

func _ready():
	animation_player.play("walk")
func _physics_process(_delta):
	if dead:
		animation_player.stop()
		return
	if standing_on == "water":
		floor_move_speed_debuff = 0.3
		$Graphics/Legs.hide()
		$WaterSplash.emitting = true
	else:
		floor_move_speed_debuff = 1.0
		$Graphics/Legs.show()
		$WaterSplash.emitting = false
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	move_direction = global_position.direction_to(player.global_position)
	velocity = move_speed * move_direction * floor_move_speed_debuff
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	
	global_rotation = move_direction.angle() + PI/2.0
	
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
	
func step():
	if standing_on == "brick":
		$ConcreteFootstep.pitch_scale = randf_range(0.8, 1.2)
		$ConcreteFootstep.play()
	if standing_on == "grass":
		$GrassFootstep.pitch_scale = randf_range(0.8, 1.2)
		$GrassFootstep.play()

