extends CharacterBody2D

@export var view_camera: Node2D #viewPorty
@export var camera: Node2D #viewPorty
@export var fog: Node2D #viewPorty

@onready var ray_cast_2d = $RayCast2D
@export var move_speed = 200
var dead = false

func _process(_delta):
	if camera != null:
		camera.position = self.position
	if fog != null:
		fog.position = self.position
	if view_camera != null:      #viewPorty
		view_camera.position = self.position
		view_camera.rotation = self.rotation
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	if dead:
		return
	
	global_rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI/2
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
func _physics_process(_delta):
	if dead:
		return
	var move_dir = Input.get_vector("move_left","move_right","move_down","move_up")
	velocity = move_dir * move_speed
	move_and_slide()
	
func kill():
	if dead:
		return
	dead = true
	$DeafSound.play()
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CanvasLayer/DeathScreen.show()
	z_index = -1
	
func restart():
	get_tree().reload_current_scene()

func shoot():
	$MuzzleFlash.show()
	$MuzzleFlash/Timer.start()
	$ShootSound.play()
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().has_method("kill"):
		ray_cast_2d.get_collider().kill()
