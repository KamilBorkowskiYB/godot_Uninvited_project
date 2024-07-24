extends CharacterBody2D

@export var view_light: Node2D #viewPorty
@export var camera: Node2D #viewPorty

@onready var ray_cast_2d = $Top/RayCast2D
@onready var animation_player = $AnimationPlayerTOP
@onready var animation_playerLegs = $AnimationPlayerLEGS
@onready var RIGHT_aim_assitst = $Top/AimAssistR
@onready var LEFT_aim_assitst = $Top/AimAssistL
@onready var bullet_trail = load("res://shot_trail.tscn")
@export var move_speed = 200
@export var push_force = 20.0
var dead = false
var target_angle = 0
var recoil = 10.0
var max_recoil = 15.0
var min_recoil = 3.0
var recoil_deg = randf_range(-recoil, recoil)

@export var can_shoot = false
@export var can_interact = true

func _ready():
	can_shoot = false
	can_interact = true

func _process(_delta):
	if camera != null:
		camera.position = self.position
	if view_light != null:      #viewPorty
		view_light.rotation = $Top.rotation
		view_light.position = self.position
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	if dead:
		return
	
	$Top.rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI/2
	var move_direction = Input.get_vector("move_left","move_right","move_down","move_up")
	$Legs.rotation = target_angle
	
	if move_direction.length_squared() > 0:
		target_angle = move_direction.angle() + PI/2
	
	if velocity.length() > 0:
		animation_playerLegs.play("walk")
		min_recoil = 6.0
		if(recoil < 6.0):
			recoil = 6.0
	else:
		animation_playerLegs.stop()
		min_recoil = 3.0
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if Input.is_action_just_pressed("Aim"):
		animation_player.play("aim")
		RIGHT_aim_assitst.show()
		LEFT_aim_assitst.show()
		move_speed = 100
	if Input.is_action_pressed("Aim"):
		recoil = max(recoil - 0.1,min_recoil)
		RIGHT_aim_assitst.rotation_degrees = recoil
		LEFT_aim_assitst.rotation_degrees = -recoil
	else:
		recoil = min(recoil + 0.1,max_recoil)
	if recoil != 0:
		recoil_deg = randf_range(-recoil, recoil)
	ray_cast_2d.rotation_degrees = recoil_deg
	
	
	if Input.is_action_just_released("Aim"):
		animation_player.play_backwards("aim")
		RIGHT_aim_assitst.hide()
		LEFT_aim_assitst.hide()
		move_speed = 200
func _physics_process(_delta):
	if dead:
		return
	var move_dir = Input.get_vector("move_left","move_right","move_down","move_up")
	velocity = move_dir * move_speed
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	
func kill():
	if dead:
		return
	dead = true
	$DeafSound.play()
	$Top/Dead.show()
	$Top/Alive.hide()
	$CanvasLayer/DeathScreen.show()
	z_index = -1
	
func restart():
	get_tree().reload_current_scene()

func shoot():
	if can_shoot == true:
		$Top/MuzzleFlash.show()
		$Top/FlashLight.show()
		$Top/MuzzleFlash/Timer.start()
		$ShootSound.play()
		var shot_trail = bullet_trail.instantiate()
		
		recoil = min(max_recoil, recoil + max_recoil * 0.7)
		
		#offset
		var direction = ray_cast_2d.global_position - get_global_mouse_position()
		direction = direction.normalized()
		var offset = direction * 70
		
		#setting bullet trail points
		shot_trail.add_point(get_parent().to_local(ray_cast_2d.global_position) - offset)
		if ray_cast_2d.is_colliding():
			shot_trail.add_point(get_parent().to_local(ray_cast_2d.get_collision_point()))
		else:
			shot_trail.add_point(get_parent().to_local(ray_cast_2d.global_position) - 100 * offset)
		get_parent().add_child(shot_trail)
		
		#killing
		if ray_cast_2d.is_colliding():
			if ray_cast_2d.get_collider().has_method("kill"):
				ray_cast_2d.get_collider().kill()
			if ray_cast_2d.get_collider().has_method("shot_reaction"):
				ray_cast_2d.get_collider().shot_reaction(direction)
		
