@tool
extends CharacterBody2D

@export var randomize_weak_points: bool = false:
	set(value):
		randomize_weak_points = false
		
		if value:
			randomize_points()
@export var hide_all: bool = false:
	set(value):
		hide_all = false
		if value:
			hide_all_weak_points()
@export var move_speed = 100
@onready var graphics = $CanvasGroup/Graphics
@onready var animation_player_top = $AnimationPlayerTop
@onready var animation_player_legs = $AnimationPlayerLegs
@onready var view_area = $ViewNodes/ViewArea
@onready var view_raycast = $ViewNodes/ViewRayCast
@onready var agro_raycast = $AgroRayCast
@onready var navigation_agent = $NavigationAgent2D
@onready var attack_area = $CanvasGroup/Graphics/Torso/LeftArm/LeftHighArm/LeftLowerArm/LeftLowerArm/Hand/AttackArea
var dead = false
var blood_splater = load("res://characters/guest/blood_splater1.png")
var blood_pool = load("res://characters/guest/blood_splater2.png")
@export var push_force = 10.0
@export var investigation_time = 5.0 # how long walks to investigate
@export var LOST_AGRO_DELAY := 3.0 # agro time
var move_direction = Vector2(0,0)
var standing_on :String = "grass"
var floor_move_speed_debuff = 1.0
var anim_move_speed_debuff = 1.0
var move_speed_debuff = floor_move_speed_debuff * anim_move_speed_debuff
@export var selected_weak_points: Array[NodePath] = []
@export var weak_point_scales: Array[float] = []
var weak_points: Array[Node] = []
enum State { CHASE, IDLE, ATTACK, LUNGE, DEAD, WALK, RECOVER }
var current_state: State = State.IDLE  
enum Return_State { RETURN_TO_ORIGIN, HANG_AROUND}
@export var ruturn_state: Return_State = Return_State.RETURN_TO_ORIGIN
@onready var origin_pos = global_position
var walk_to_pos = Vector2(0.0, 0.0)
var investigating := false
@onready var rot_to = global_rotation
var lost_sight_time := 0.0
var turn_speed := 5.0
@export var health = 100
var damage = 5
var tween_done := false
var sound_done := false
var recovery_time := 0.0
var recovery_stop_time := 0.0
var recovery_total_time := 1.5


func _ready():
	if Engine.is_editor_hint():
		return
	connect_signals_bodyparts_recursive(self)
	weak_points = []
	find_weak_points(self, weak_points)
	
	for i in range(0, weak_points.size()):
		weak_points[i].got_shot.connect(take_damage)
		if !selected_weak_points.has(get_path_to(weak_points[i])):
			weak_points[i].queue_free()
			
	for i in range(selected_weak_points.size()):
		var weak_point = get_node_or_null(selected_weak_points[i])
		if weak_point:
			weak_point.show()
			weak_point.scale = Vector2(
				weak_point_scales[i],
				weak_point_scales[i]
			)
	
	animation_player_top.play("idle")
	animation_player_legs.play("walk")
	
	$Sounds/DeathSound.finished.connect(on_sound_done)
	
	walk_timer = Timer.new()
	walk_timer.one_shot = true
	add_child(walk_timer)
	walk_timer.timeout.connect(return_to_origin)
	
	attack_area.body_attacked.connect(deal_damage)


func _physics_process(_delta):
	if Engine.is_editor_hint():
		return
	if dead:
		animation_player_top.stop()
		animation_player_legs.speed_scale = 0.0
		return
	if standing_on == "water":
		floor_move_speed_debuff = 0.3
		graphics.get_node("Legs").hide()
		$WaterSplash.emitting = true
	else:
		floor_move_speed_debuff = 1.0
		graphics.get_node("Legs").show()
		$WaterSplash.emitting = false
	
	move_speed_debuff = floor_move_speed_debuff * anim_move_speed_debuff
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player:
		view_raycast.target_position = view_raycast.to_local(player.global_position)
	
	if player in view_area.get_overlapping_bodies() and view_raycast.get_collider() == player:
		lost_sight_time = 0.0
		player_spoted()
	elif current_state == State.CHASE:
		lost_sight_time += _delta
		if lost_sight_time >= LOST_AGRO_DELAY:
			player_lost()
	if current_state == State.CHASE or current_state == State.RECOVER:
		var distance_to_player := global_position.distance_to(player.global_position)
		if distance_to_player <= 120.0:
			move_speed = 0
		else:
			move_speed = 100
		if navigation_agent.target_position.distance_to(player.global_position) > 16.0:
			navigation_agent.target_position = player.global_position
		var next_point = navigation_agent.get_next_path_position()
		move_direction = global_position.direction_to(next_point)
	elif current_state == State.LUNGE:
		move_direction = global_position.direction_to(agro_raycast.to_global(agro_raycast.target_position))
	elif current_state == State.WALK:
		navigation_agent.target_position = walk_to_pos
		var next_point = navigation_agent.get_next_path_position()
		move_direction = global_position.direction_to(next_point)
		
	if current_state == State.CHASE or current_state == State.LUNGE or current_state == State.WALK or current_state == State.ATTACK:
		if current_state == State.WALK and global_position.distance_to(walk_to_pos) < 30:
			set_idle()
		
		velocity = move_speed * move_direction * move_speed_debuff
		if move_speed != 0: move_and_slide()
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
		
		rot_to = move_direction.angle() + PI/2.0
	
	
	if current_state == State.RECOVER:
		recovery_time += _delta
		if recovery_time < recovery_stop_time:
			velocity = Vector2.ZERO
			turn_speed = 0.0
		else:
			var recovery_progress = clamp((recovery_time - recovery_stop_time) / (recovery_total_time - recovery_stop_time), 0.0, 1.0)
			anim_move_speed_debuff = lerp(0.0, 2.2, recovery_progress) #2.2 is the basic anim speed
			move_speed_debuff = floor_move_speed_debuff * anim_move_speed_debuff
			velocity = move_speed * move_direction * move_speed_debuff
			if move_speed != 0: move_and_slide()
			turn_speed = lerp(0.0, 5.0, recovery_progress)
			rot_to = move_direction.angle() + PI/2.0
	else:
		turn_speed = 5.0
	
	animation_player_legs.speed_scale = velocity.length() / 220 #220 is the basic speed
	global_rotation = lerp_angle(
		global_rotation,
		rot_to,
		turn_speed * _delta
	)
	
	if agro_raycast.is_colliding() and current_state == State.CHASE:
		var target = agro_raycast.get_collider()
		if target == null: return
		var dist_to_target = global_position.distance_to(target.global_position)
		if target == player:
			if dist_to_target >= 200:
				attack_lunge()
			else:
				attack()
		elif target.is_in_group("movable_blocks") or target.get_parent().is_in_group("movable_blocks"):
			if dist_to_target < 150: attack()


func take_damage(attack_info: Attack):
	if dead:
		return
	spawn_blood(attack_info.attack_direction, attack_info.attack_impact_position)
	if randi_range(0, 1) == 0:
		if $Sounds/DamageTaken2.playing == false and $Sounds/DamageTaken.playing == false:
			$Sounds/DamageTaken.play()
	else:
		if $Sounds/DamageTaken2.playing == false and $Sounds/DamageTaken.playing == false:
			$Sounds/DamageTaken2.play()
	health -= attack_info.attack_damage
	lost_sight_time = 0.0
	player_spoted()
	if health <= 0:
		kill(attack_info)


func kill(_attack: Attack):
	if dead:
		return
	spawn_corpse()
	spawn_corpse()
	spawn_corpse()
	
	for i in range(0, weak_points.size()):
		if is_instance_valid(weak_points[i]):
			weak_points[i].queue_free()
	dead = true
	
	if $Sounds/DamageTaken.playing:
		$Sounds/DamageTaken.playing = false
	if $Sounds/DamageTaken2.playing:
		$Sounds/DamageTaken2.playing = false
	$Sounds/DeathSound.play()
	start_death_effect()
	$CollisionShape2D.disabled = true
	z_index = -1


#func find_weak_points(node: Node):
	#for child in node.get_children():
		#if child.is_in_group("weak_point"):
			#weak_points.append(child)
		#find_weak_points(child)


func step():
	if standing_on == "brick":
		$Sounds/ConcreteFootstep.pitch_scale = randf_range(0.8, 1.2)
		$Sounds/ConcreteFootstep.play()
	if standing_on == "grass":
		$Sounds/GrassFootstep.pitch_scale = randf_range(0.8, 1.2)
		$Sounds/GrassFootstep.play()


func player_spoted():
	if current_state == State.LUNGE or current_state == State.ATTACK or current_state == State.CHASE or current_state == State.RECOVER:
		return
	current_state = State.CHASE
	if animation_player_top.current_animation != "chase":
		animation_player_top.play("chase")
	animation_player_top.speed_scale = 1.3
	anim_move_speed_debuff = 2.2


func player_lost():
	if current_state == State.LUNGE or current_state == State.ATTACK or current_state == State.WALK:
		return
	investigating = false
	curr_noise_lvl = 0
	if ruturn_state  == Return_State.HANG_AROUND:
		set_idle()
	if ruturn_state == Return_State.RETURN_TO_ORIGIN:
		walk_to(origin_pos, true)


func set_idle():
	if current_state == State.LUNGE or current_state == State.ATTACK:
		return
	current_state = State.IDLE
	animation_player_top.play("idle")
	animation_player_top.speed_scale = 1.0
	velocity = Vector2.ZERO
	anim_move_speed_debuff = 1.0


var walk_timer: Timer
func walk_to(destination, persistent):
	if current_state == State.LUNGE or current_state == State.ATTACK:
		return
	if walk_timer:
		walk_timer.stop()
	if !persistent:
		walk_timer.start(investigation_time)
	current_state = State.WALK
	walk_to_pos = destination
	animation_player_top.play("idle")
	animation_player_top.speed_scale = 1.0
	anim_move_speed_debuff = 1.0

var return_timer: SceneTreeTimer
var return_id := 0
func return_to_origin():
	if current_state != State.WALK:
		return
	set_idle()
	return_id += 1
	var my_id := return_id
	return_timer = get_tree().create_timer(2.0)
	await return_timer.timeout
	
	if my_id != return_id:
		return
	if current_state != State.IDLE and current_state != State.WALK:
		return
	
	investigating = false
	curr_noise_lvl = 0
	walk_to(origin_pos, true)
	return_timer = null


var investigate_timer: SceneTreeTimer
var investigate_id := 0
var curr_noise_lvl = 0
func investigate_noise(noise_pos: Vector2, noise_lvl):
	if current_state != State.IDLE and current_state != State.WALK:
		return
	if !investigating:
		set_idle()
	if walk_timer:
		walk_timer.stop()
	return_id += 1
	var my_id
	if curr_noise_lvl <= noise_lvl:
		curr_noise_lvl = noise_lvl
		investigate_id += 1
		my_id = investigate_id
		
		rot_to = global_position.direction_to(noise_pos).angle() + PI / 2.0
	
	if !investigating:
		investigate_timer = get_tree().create_timer(2.0)
		await investigate_timer.timeout
		
	var chance = randi_range(0, 1)
	if my_id != investigate_id and chance == 1:
		return
	if current_state != State.IDLE and current_state != State.WALK:
		return
	
	if investigating and noise_lvl >= curr_noise_lvl:
		investigating = true
		walk_to(noise_pos, false)
	else:
		if chance == 0:
			investigating = true
			walk_to(noise_pos, false)
		else:
			rot_to = randf_range(global_rotation - 30.0, global_rotation + 30.0)
			player_lost()
	investigate_timer = null


func attack():
	if current_state == State.LUNGE or current_state == State.ATTACK:
		return
	current_state = State.ATTACK
	if !(animation_player_top.current_animation  == "attack"):
		animation_player_top.play("attack")


func attack_lunge():
	if current_state == State.LUNGE or current_state == State.ATTACK:
		return
	current_state = State.LUNGE
	anim_move_speed_debuff = 5.5
	if !(animation_player_top.current_animation  == "lunge_new"):
		animation_player_top.play("lunge_new")


func attack_ended(attack_type): #1-attack, 2-lunge
	#Recovery
	velocity = Vector2.ZERO
	current_state = State.RECOVER
	recovery_time = 0.0
	if attack_type == 1:
		animation_player_top.play("recovery_attack")
		animation_player_top.queue("idle")
		recovery_stop_time = 0.0
		recovery_total_time = 1.5
	else:
		animation_player_top.play("recovery_attack")
		animation_player_top.queue("idle")
		recovery_stop_time = 1.0
		recovery_total_time = 2.5
	animation_player_top.speed_scale = 1.0
	anim_move_speed_debuff = 0.0
	await get_tree().create_timer(recovery_total_time).timeout
	
	anim_move_speed_debuff = 1.0
	current_state = State.IDLE
	player_spoted()


func deal_damage(body):
	await get_tree().physics_frame
	var direction = (global_position - body.global_position).normalized()
	var attack_info = Attack.new()
	attack_info.attack_damage = damage
	attack_info.attack_direction = direction
	attack_info.attack_source_name = self.name
	if body.has_method("take_damage"):
		body.take_damage(attack_info)
	elif body.has_method("kill"):
		body.kill(attack_info)


func start_death_effect():
	var mat = $CanvasGroup.material
	var tween = create_tween()
	tween.tween_method(
		func(v):
			mat.set_shader_parameter("strength", v),
		0.0,
		1.0,
		0.5
	)
	
	await tween.finished
	on_tween_done()

func connect_signals_bodyparts_recursive(node: Node):
	for child in node.get_children():
		if child.has_signal("got_hit_head"):
			child.got_hit_head.connect(take_damage)
		connect_signals_bodyparts_recursive(child)

func on_tween_done():
	tween_done = true
	check_death_cleanup()


func on_sound_done():
	sound_done = true
	check_death_cleanup()


func check_death_cleanup():
	if tween_done and sound_done:
		queue_free()



func spawn_blood(direction, impact_position):
	var blood := Sprite2D.new()
	blood.texture = blood_splater
	blood.global_position = impact_position
	blood.scale = Vector2(0.2, 0.2)
	blood.rotation = randf_range(0.0, 180.0)
	blood.z_index = -1
	blood.hframes = 2
	blood.frame = randi_range(0, 1)
	
	get_parent().add_child(blood)
	var distance := randf_range(150.0, 240.0)
	var target_position = blood.global_position - direction.rotated(randf_range(-0.5, 0.5)) * distance
	
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		blood.global_position,
		target_position
	)
	# If high block will collide with blood, then so will enemies
	query.collision_mask = 1 | 4 | 8
	var result := space_state.intersect_ray(query)
	if result:
		var wall_distance := blood.global_position.distance_to(result.position)
		var target_distance := blood.global_position.distance_to(target_position)
		if wall_distance < target_distance:
			target_position = result.position
	
	var target_scale = randf_range(0.6, 1.3)
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(
		blood,
		"global_position",
		target_position,
		0.4
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	
	tween.tween_property(
		blood,
		"scale",
		Vector2(target_scale,target_scale),
		0.6
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	tween.chain().tween_interval(1.0)


func spawn_corpse():
	var blood := Sprite2D.new()
	blood.texture = blood_pool
	var position_offset := Vector2(randf_range(-50.0, 50.0), randf_range(-50.0, 50.0))
	blood.global_position = global_position + position_offset
	blood.scale = Vector2(0.2, 0.2)
	blood.rotation = randf_range(0.0, 180.0)
	blood.z_index = -1
	
	get_parent().add_child(blood)
	
	var target_scale = randf_range(1.0, 1.5)
	var tween := create_tween()
	tween.tween_property(
		blood,
		"scale",
		Vector2(target_scale,target_scale),
		1.5
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func randomize_points():
	weak_points = []
	selected_weak_points = []
	weak_point_scales = []
	var weak_points_count = randi_range(3, 5)
	find_weak_points(self, weak_points)
	
	weak_points.shuffle()
	for i in range(weak_points_count, weak_points.size()):
		weak_points[i].hide()
		
	for i in range(0, weak_points_count):
		var s = randf_range(0.7, 1.3)
		weak_points[i].scale = Vector2(s, s)
		weak_points[i].show()
		selected_weak_points.append(get_path_to(weak_points[i]))
		weak_point_scales.append(s)


func hide_all_weak_points():
	weak_points = []
	selected_weak_points = []
	find_weak_points(self, weak_points)
	for i in range(0, weak_points.size()):
		weak_points[i].hide()

func find_weak_points(node: Node, result: Array[Node]):
	for child in node.get_children():
		if child.is_in_group("weak_point"):
			result.append(child)
		find_weak_points(child, result)
