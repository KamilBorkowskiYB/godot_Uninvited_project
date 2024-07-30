extends CharacterBody2D

signal player_has_died

var view_light: Node2D #Connects view with player
var aim_assist: Node2D 
var aim_assistR: Node2D 
var aim_assistL: Node2D 

##########        CURSORS        ##########
@onready var cursor_interact = load("res://cursor/cursor_interact.png")
@onready var cursor_aim = load("res://cursor/cursor_aim.png")
@onready var cursor_normal = load("res://cursor/cursor_normal.png")
var cursor_current = null

##########        PLAYER NODES        ##########
@onready var ray_cast1 = $Top/RayCasts/RayCast2D
@onready var ray_cast2 = $Top/RayCasts/RayCast2D2
@onready var ray_cast3 = $Top/RayCasts/RayCast2D3
@onready var ray_cast4 = $Top/RayCasts/RayCast2D4
@onready var animation_player = $AnimationPlayerTOP
@onready var animation_playerLegs = $AnimationPlayerLEGS
@onready var RIGHT_aim_assitst = $Top/AimAssistR
@onready var LEFT_aim_assitst = $Top/AimAssistL
@onready var bullet_trail = load("res://shot_trail.tscn")
@export var move_speed = 200
@export var push_force = 20.0
var dead = false
var leg_direction_angle = 0
var weapon_selected = 0 #0-rifle	1-shotgun
@export var can_shoot = false
@export var can_interact = true #not used at the moment

##########        WEAPON STATS         ##########
#rifle
const RIFLE_MAX_RECOIL = 15.0
const RIFLE_MIN_RECOIL = 3.0
const RIFLE_BASE_RECOIL = 10.0
const RIFLE_FOCUS_SPEED = 0.1
const RIFLE_DMG = 30.0
const RIFLE_AIM_ANIM = "aim"
#shotgun
const SHOTGUN_MAX_RECOIL = 40.0
const SHOTGUN_MIN_RECOIL = 10.0
const SHOTGUN_FOCUS_SPEED = 0.4
const SHOTGUN_DMG = 15
const SHOTGUN_AIM_ANIM = "aim_shotgun"
#defalut
var max_recoil = RIFLE_MAX_RECOIL
var min_recoil = RIFLE_MIN_RECOIL#dynamic min recoil based of walking, etc.
var recoil = RIFLE_BASE_RECOIL
var recoil_focus_speed = RIFLE_FOCUS_SPEED
var floor_min_recoil = RIFLE_MIN_RECOIL #static min recoil based of weapon
var damage = RIFLE_DMG
var animation_aim = RIFLE_AIM_ANIM

##########        CALCULATIN RAYCAST ROTATION        ##########
var recoil_deg = randf_range(-recoil, recoil)
var recoil_deg2 = randf_range(-recoil, recoil)
var recoil_deg3 = randf_range(-recoil, recoil)
var recoil_deg4 = randf_range(-recoil, recoil)

func _ready():
	can_shoot = false
	can_interact = true

func _process(_delta):
	##########        CONNECTING NODES FROM VIEWPORTS         ##########
	if aim_assist != null:
		aim_assist.position = self.position
		aim_assist.rotation = $Top.rotation
		aim_assistR.rotation = $Top/AimAssistR.rotation
		aim_assistL.rotation = $Top/AimAssistL.rotation
		aim_assistR.visible = $Top/AimAssistR.visible
		aim_assistL.visible = $Top/AimAssistL.visible
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
		min_recoil = floor_min_recoil * 2
		if(recoil < min_recoil):
			recoil = min_recoil
	else:
		animation_playerLegs.stop()
		min_recoil = floor_min_recoil
		
	##########        INPUTS         ##########
	if Input.is_action_just_pressed("shoot"):
		if weapon_selected == 0:
			shoot([ray_cast1])
		elif weapon_selected == 1:
			shoot([ray_cast1,ray_cast2,ray_cast3,ray_cast4])
	
	if Input.is_action_just_pressed("weapon_1"):
		change_weapon(0,0,RIFLE_MAX_RECOIL,RIFLE_MIN_RECOIL,RIFLE_DMG,RIFLE_FOCUS_SPEED,RIFLE_AIM_ANIM)
	
	if Input.is_action_just_pressed("weapon_2"):
		change_weapon(5,1,SHOTGUN_MAX_RECOIL,SHOTGUN_MIN_RECOIL,SHOTGUN_DMG,SHOTGUN_FOCUS_SPEED,SHOTGUN_AIM_ANIM)
	
	if Input.is_action_just_pressed("Aim"):
		animation_player.play(animation_aim)
		animation_playerLegs.speed_scale = 0.7
		RIGHT_aim_assitst.show()
		LEFT_aim_assitst.show()
		Input.set_custom_mouse_cursor(cursor_aim,Input.CURSOR_ARROW,Vector2(24,24))
		cursor_current = cursor_aim
		move_speed = 100
	if Input.is_action_pressed("Aim"):
		recoil = max(recoil - recoil_focus_speed,min_recoil)
		RIGHT_aim_assitst.rotation_degrees = recoil
		LEFT_aim_assitst.rotation_degrees = -recoil
	else:
		recoil = min(recoil + 0.1,max_recoil)
	if recoil != 0:
		recoil_deg = randf_range(-recoil, recoil)
		recoil_deg2 = randf_range(-recoil, recoil)
		recoil_deg3 = randf_range(-recoil, recoil)
		recoil_deg4 = randf_range(-recoil, recoil)
	ray_cast1.rotation_degrees = recoil_deg
	ray_cast2.rotation_degrees = recoil_deg2
	ray_cast3.rotation_degrees = recoil_deg3
	ray_cast4.rotation_degrees = recoil_deg4
	
	if Input.is_action_just_released("Aim"):
		animation_player.play_backwards(animation_aim)
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

func shoot(ray_casts):
	if can_shoot == true:
		$Top/MuzzleFlash.show()
		$Top/FlashLight.show()
		$Top/MuzzleFlash/Timer.start()
		$Sounds/ShootSound.play()
		get_parent().start_shake(10, 0.1) 
		recoil = min(max_recoil, recoil + max_recoil * 0.7)
		
		# Iterate through all RayCast2D
		for ray_cast in ray_casts:
			var direction = ray_cast.global_position - get_global_mouse_position()
			direction = direction.normalized()
			var offset = direction * 70
			
			var shot_trail = bullet_trail.instantiate()
			
			# Setting bullet trail points
			shot_trail.add_point(get_parent().to_local(ray_cast.global_position) - offset)
			if ray_cast.is_colliding():
				shot_trail.add_point(get_parent().to_local(ray_cast.get_collision_point()))
			#else:
				#var offset_x = cos(ray_cast.rotation_degrees) * 700
				#var offset_y = sin(ray_cast.rotation_degrees) * 700
				#var end_point = Vector2(offset_x,offset_y)
				#print(ray_cast.rotation_degrees)
				#ray_cast.position += end_point
				#shot_trail.add_point(get_parent().to_local(ray_cast.global_position))
				#shot_trail.add_point(get_parent().to_local(ray_cast.global_position) - 100 * offset)
			get_parent().add_child(shot_trail)
			
			# Killing
			if ray_cast.is_colliding():
				if ray_cast.get_collider().has_method("kill"):
					var attack = Attack.new()
					attack.attack_damage = 50.0
					attack.attack_direction = direction
					ray_cast.get_collider().kill(attack)

func change_weapon(frame,wep_num,max_rec,min_rec,dmg,rec_sped,anim_aim):
	if cursor_current != cursor_aim:
		$Top/Alive.frame = frame
		max_recoil = max_rec
		min_recoil = min_rec
		damage = dmg
		recoil_focus_speed = rec_sped
		weapon_selected = wep_num
		floor_min_recoil = min_rec
		animation_aim = anim_aim
		recoil = max_rec * 0.7

