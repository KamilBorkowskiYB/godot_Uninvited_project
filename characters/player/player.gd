extends CharacterBody2D

signal player_has_died

@export var view_light: Node2D #Connects view with player
@export var camera: Node2D #not used

##########        CURSORS        ##########
@onready var cursor_interact = load("res://cursor/cursor_interact.png")
@onready var cursor_aim = load("res://cursor/cursor_aim.png")
@onready var cursor_normal = load("res://cursor/cursor_normal.png")
var cursor_current = null

##########        PLAYER NODES        ##########
@onready var ray_cast_2d = $Top/RayCast2D
@onready var animation_player = $AnimationPlayerTOP
@onready var animation_playerLegs = $AnimationPlayerLEGS
@onready var RIGHT_aim_assitst = $Top/AimAssistR
@onready var LEFT_aim_assitst = $Top/AimAssistL
@onready var bullet_trail = load("res://shot_trail.tscn")
@export var move_speed = 200
@export var push_force = 20.0
var dead = false
var leg_direction_angle = 0
@export var can_shoot = false
@export var can_interact = true

##########        SHOOTING RECOIL         ##########
var recoil = 10.0
var max_recoil = 15.0
var min_recoil = 3.0
var recoil_deg = randf_range(-recoil, recoil)

func _ready():
	can_shoot = false
	can_interact = true

func _process(_delta):
	##########        CONNECTING NODES FROM VIEWPORTS         ##########
	if camera != null:
		camera.position = self.position
	if view_light != null:      #viewPorty
		view_light.rotation = $Top.rotation
		view_light.position = self.position
	##########        EXITING         ##########
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	##########        IF DEAD DO NOTHING         ##########
	if dead:
		return
		
	##########        TOP AND LEGS ROTATION         ##########
	$Top.rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI/2
	var move_direction = Input.get_vector("move_left","move_right","move_down","move_up")
	$Legs.rotation = leg_direction_angle
	
	if velocity.length() > 0:
		animation_playerLegs.play("walk")
		leg_direction_angle = move_direction.angle() + PI/2
		min_recoil = 6.0
		if(recoil < 6.0):
			recoil = 6.0
	else:
		animation_playerLegs.stop()
		min_recoil = 3.0
		
	##########        INPUTS         ##########
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	if Input.is_action_just_pressed("Aim"):
		animation_player.play("aim")
		animation_playerLegs.speed_scale = 0.7
		RIGHT_aim_assitst.show()
		LEFT_aim_assitst.show()
		Input.set_custom_mouse_cursor(cursor_aim,Input.CURSOR_ARROW,Vector2(24,24))
		cursor_current = cursor_aim
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
		animation_playerLegs.speed_scale = 1
		RIGHT_aim_assitst.hide()
		LEFT_aim_assitst.hide()
		Input.set_custom_mouse_cursor(cursor_normal,Input.CURSOR_ARROW,Vector2(24,24))
		cursor_current = cursor_normal
		move_speed = 200

func _physics_process(_delta):
	if dead:
		return
	##########        MOVING         ##########
	var move_dir = Input.get_vector("move_left","move_right","move_down","move_up")
	velocity = move_dir * move_speed
	move_and_slide()
	##########        COLIDING WITH RIGIDBODYS         ##########
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

func kill():
	if dead:
		return
	dead = true
	$Sounds/DeafSound.play()
	$Top/Dead.show()
	$Top/Alive.hide()
	$Legs.hide()
	z_index = -1
	emit_signal("player_has_died")

func shoot():
	if can_shoot == true:
		$Top/MuzzleFlash.show()
		$Top/FlashLight.show()
		$Top/MuzzleFlash/Timer.start()
		$Sounds/ShootSound.play()
		var shot_trail = bullet_trail.instantiate()
		get_parent().start_shake(10, 0.1) 
		recoil = min(max_recoil, recoil + max_recoil * 0.7)
		
		#bullet trail offset
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
		
