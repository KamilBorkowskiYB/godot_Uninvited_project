extends CharacterBody2D

@export var view_camera: Node2D #viewPorty
@export var camera: Node2D #viewPorty
@export var fog: Node2D #viewPorty

@onready var ray_cast_2d = $Top/RayCast2D
@onready var animation_player = $AnimationPlayerTOP
@onready var animation_playerLegs = $AnimationPlayerLEGS
@export var move_speed = 200
@export var push_force = 20.0
var dead = false
var target_angle = 0

@export var can_shoot = false
func _ready():
	can_shoot = false
	
func _process(_delta):
	if camera != null:
		camera.position = self.position
	if fog != null:
		fog.position = self.position
	if view_camera != null:      #viewPorty
		view_camera.rotation = $Top.rotation
		view_camera.position = self.position
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	if dead:
		return
	
	#global_rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI/2
	$Top.rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI/2
	var move_direction = Input.get_vector("move_left","move_right","move_down","move_up")
	$Legs.rotation = target_angle
	
	if move_direction.length_squared() > 0:
		target_angle = move_direction.angle() + PI/2
	
	if velocity.length() > 0:
		animation_playerLegs.play("walk")
	else:
		animation_playerLegs.stop()
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if Input.is_action_just_pressed("Aim"):
		animation_player.play("aim")
		move_speed = 100
	if Input.is_action_just_released("Aim"):
		animation_player.play_backwards("aim")
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
		if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().has_method("kill"):
			ray_cast_2d.get_collider().kill()
