extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

@export var move_speed = 100
@onready var animation_player_top = $AnimationPlayerTop
@onready var animation_player_legs = $AnimationPlayerLegs
var dead = false
@export var push_force = 10.0
var move_direction = Vector2(0,0)
var standing_on :String = "grass"
var floor_move_speed_debuff = 1.0
var weak_points = []
var keep_count
#TODO Lounge attack and mutant like aggro
func _ready():
	find_weak_points(self)
	keep_count = randi_range(3, 5)
	weak_points.shuffle()
	for i in range(keep_count, weak_points.size()):
		weak_points[i].queue_free()
	for i in range(0, keep_count):
		var s = randf_range(0.7, 1.3)
		weak_points[i].scale = Vector2(s, s)
		weak_points[i].show()
	animation_player_top.play("chase")
	animation_player_legs.play("walk")
	
func _physics_process(_delta):
	if dead:
		animation_player_top.stop()
		animation_player_legs.stop()
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
	for i in range(0, keep_count):
		if is_instance_valid(weak_points[i]):
			weak_points[i].queue_free()
	dead = true
	$DeathSound.play()
	$Graphics.hide()
	$CollisionShape2D.disabled = true
	z_index = -1


func find_weak_points(node: Node):
	for child in node.get_children():
		if child.is_in_group("weak_point"):
			weak_points.append(child)
		find_weak_points(child)


func step():
	if standing_on == "brick":
		$ConcreteFootstep.pitch_scale = randf_range(0.8, 1.2)
		$ConcreteFootstep.play()
	if standing_on == "grass":
		$GrassFootstep.pitch_scale = randf_range(0.8, 1.2)
		$GrassFootstep.play()

