extends CharacterBody2D


@export var move_speed = 100
@onready var animation_player_top = $AnimationPlayerTop
@onready var animation_player_legs = $AnimationPlayerLegs
@onready var view_area = $ViewNodes/ViewArea
@onready var view_raycast = $ViewNodes/ViewRayCast
@onready var agro_raycast = $AgroRayCast
var dead = false
@export var push_force = 10.0
var move_direction = Vector2(0,0)
var standing_on :String = "grass"
var floor_move_speed_debuff = 1.0
var anim_move_speed_debuff = 1.0
var move_speed_debuff = floor_move_speed_debuff * anim_move_speed_debuff
var weak_points = []
var keep_count
enum State { CHASE, IDLE, ATTACK, LUNGE, DEAD }
var current_state: State = State.IDLE  
var lost_sight_time := 0.0
const LOST_AGRO_DELAY := 3.0
var turn_speed := 5.0

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
	animation_player_top.play("idle")


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
	
	move_speed_debuff = floor_move_speed_debuff * anim_move_speed_debuff
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player:
		view_raycast.target_position = view_raycast.to_local(player.global_position)
	
	if  player in view_area.get_overlapping_bodies() and view_raycast.get_collider() == player:
		lost_sight_time = 0.0
		player_spoted()
	else:
		lost_sight_time += _delta
		if lost_sight_time >= LOST_AGRO_DELAY:
			player_lost()
	if current_state == State.CHASE:
		move_direction = global_position.direction_to(player.global_position)
		velocity = move_speed * move_direction * move_speed_debuff
		move_and_slide()
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
		
		global_rotation = lerp_angle(
			global_rotation,
			move_direction.angle() + PI/2.0,
			turn_speed * _delta
		)
	elif current_state == State.LUNGE:
		move_direction = global_position.direction_to(agro_raycast.to_global(agro_raycast.target_position))
		velocity = move_speed * move_direction * move_speed_debuff
		move_and_slide()
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	
	if agro_raycast.is_colliding() and agro_raycast.get_collider() == player and current_state == State.CHASE:
		var dist_to_player = global_position.distance_to(player.global_position)
		if dist_to_player >= 200:
			attack_lunge()
		else:
			attack()


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


func player_spoted():
	if current_state == State.LUNGE or current_state == State.ATTACK:
		return
	current_state = State.CHASE
	animation_player_top.play("chase")
	animation_player_top.speed_scale = 1.3
	animation_player_legs.play("walk")
	anim_move_speed_debuff = 2.2


func player_lost():
	if current_state == State.LUNGE or current_state == State.ATTACK:
		return
	current_state = State.IDLE
	animation_player_top.play("idle")
	animation_player_top.speed_scale = 1.0
	animation_player_legs.stop()
	anim_move_speed_debuff = 1.0


func attack():
	current_state = State.ATTACK
	if !(animation_player_top.current_animation  == "attack"):
		animation_player_top.play("attack")


func attack_lunge():
	current_state = State.LUNGE
	anim_move_speed_debuff = 4.0
	if !(animation_player_top.current_animation  == "lunge"):
		animation_player_top.play("lunge")


func attack_ended():# should be called in the lunge anim at the end
	current_state = State.IDLE
	player_spoted()
