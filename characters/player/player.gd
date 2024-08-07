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

##########        FOOTSTEPS        ##########
enum FloorMaterial {Grass, Concrete, Water}
var stands_on := FloorMaterial.Concrete #floor changes this on ready()

##########        PICK UPS        ##########
var pistol_unlock = 1
var pistol_ammo = 20
var rifle_unlock = 1 #remember to update pickUp.gd with every new pick up
var rifle_ammo = 5
var shotgun_unlock = 0
var shotgun_shells = 0

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
var weapon_selected  #0-rifle	1-shotgun 	2-pistol
@export var can_shoot = false
@export var can_interact = true #not used at the moment

##########        WEAPON STATS         ##########
#pistol
const PISTOL_MAX_RECOIL = 20.0
const PISTOL_MIN_RECOIL = 6.0
const PISTOL_FOCUS_SPEED = 0.2
const PISTOL_DMG = 10.0
const PISTOL_AIM_ANIM = "aim_pistol"
const PISTOL_AIMED_ANIM = "aimed_pistol"
const PISTOL_MUZZLE_FLASH = Vector2(-1,-86)
#rifle
const RIFLE_MAX_RECOIL = 15.0
const RIFLE_MIN_RECOIL = 3.0
const RIFLE_FOCUS_SPEED = 0.1
const RIFLE_DMG = 30.0
const RIFLE_AIM_ANIM = "aim"
const RIFLE_AIMED_ANIM = "aimed_rifle"
const RIFLE_MUZZLE_FLASH = Vector2(3,-89)
#shotgun
const SHOTGUN_MAX_RECOIL = 40.0
const SHOTGUN_MIN_RECOIL = 10.0
const SHOTGUN_FOCUS_SPEED = 0.4
const SHOTGUN_DMG = 15
const SHOTGUN_AIM_ANIM = "aim_shotgun"
const SHOTGUN_AIMED_ANIM = "aimed_shotgun"
const SHOTGUN_MUZZLE_FLASH = Vector2(1,-81)
#defalut
var max_recoil = RIFLE_MAX_RECOIL
var min_recoil = RIFLE_MIN_RECOIL#dynamic min recoil based of walking, etc.
var recoil = max_recoil * 0.7
var recoil_focus_speed = RIFLE_FOCUS_SPEED
var floor_min_recoil = RIFLE_MIN_RECOIL #static min recoil based of weapon
var damage = RIFLE_DMG
var animation_aim = RIFLE_AIM_ANIM
var animation_aimed = RIFLE_AIMED_ANIM

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
		$Legs.rotation = $Top.rotation
		animation_playerLegs.stop()
		min_recoil = floor_min_recoil
		
	##########        INPUTS         ##########
	if Input.is_action_just_pressed("shoot"):
		if weapon_selected == 0 and rifle_ammo > 0:
			rifle_ammo = shoot([ray_cast1], rifle_ammo)
		elif weapon_selected == 1 and shotgun_shells > 0:
			shotgun_shells = shoot([ray_cast1,ray_cast2,ray_cast3,ray_cast4], shotgun_shells)
		elif weapon_selected == 2 and pistol_ammo > 0:
			pistol_ammo = shoot([ray_cast1], pistol_ammo)
	
	if Input.is_action_just_pressed("weapon_1"):
		if rifle_unlock > 0:
			change_weapon(39,0,RIFLE_MAX_RECOIL,RIFLE_MIN_RECOIL,
			RIFLE_DMG,RIFLE_FOCUS_SPEED,RIFLE_AIM_ANIM,RIFLE_AIMED_ANIM,RIFLE_MUZZLE_FLASH)
	
	if Input.is_action_just_pressed("weapon_2"):
		if shotgun_unlock > 0:
			change_weapon(52,1,SHOTGUN_MAX_RECOIL,SHOTGUN_MIN_RECOIL,
			SHOTGUN_DMG,SHOTGUN_FOCUS_SPEED,SHOTGUN_AIM_ANIM,SHOTGUN_AIMED_ANIM,SHOTGUN_MUZZLE_FLASH)
	
	if Input.is_action_just_pressed("weapon_3"):
		if pistol_unlock > 0:
			change_weapon(13,2,PISTOL_MAX_RECOIL,PISTOL_MIN_RECOIL,
			PISTOL_DMG,PISTOL_FOCUS_SPEED,PISTOL_AIM_ANIM,PISTOL_AIMED_ANIM,PISTOL_MUZZLE_FLASH)
	
	if Input.is_action_just_pressed("Aim"):
		if weapon_selected == null:
			return
		animation_player.play(animation_aim)
		animation_player.queue(animation_aimed)
		animation_playerLegs.speed_scale = 0.7
		RIGHT_aim_assitst.show()
		LEFT_aim_assitst.show()
		Input.set_custom_mouse_cursor(cursor_aim,Input.CURSOR_ARROW,Vector2(24,24))
		cursor_current = cursor_aim
		move_speed = 100
	if Input.is_action_pressed("Aim"):
		if weapon_selected == null:
			return
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
		if weapon_selected == null:
			return
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

func shoot(ray_casts,ammo_type):
	if can_shoot == true:
		$Top/MuzzleFlash.show()
		$Top/FlashLight.show()
		$Top/MuzzleFlash/Timer.start()
		$Sounds/ShootSound.play()
		get_parent().start_shake(10, 0.1) 
		recoil = min(max_recoil, recoil + max_recoil * 0.7)
		ammo_type -= 1
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
			get_parent().add_child(shot_trail)
			
			# Killing
			if ray_cast.is_colliding():
				if ray_cast.get_collider().has_method("kill"):
					var attack = Attack.new()
					attack.attack_damage = damage
					attack.attack_direction = direction
					ray_cast.get_collider().kill(attack)
	return ammo_type

func change_weapon(frame,wep_num,max_rec,min_rec,dmg,rec_sped,anim_aim,anim_aimed,muzzle_ofset):
	if cursor_current != cursor_aim and !animation_player.is_playing():
		$Top/Alive.frame = frame
		max_recoil = max_rec
		min_recoil = min_rec
		damage = dmg
		recoil_focus_speed = rec_sped
		weapon_selected = wep_num
		floor_min_recoil = min_rec
		animation_aim = anim_aim
		animation_aimed = anim_aimed
		recoil = max_rec * 0.7
		$Top/MuzzleFlash.position = muzzle_ofset

func step():
	if stands_on == FloorMaterial.Concrete:
		$Sounds/ConcreteFootstep.pitch_scale = randf_range(0.8, 1.2)
		$Sounds/ConcreteFootstep.play()
	if stands_on == FloorMaterial.Grass:
		$Sounds/GrassFootstep.pitch_scale = randf_range(0.8, 1.2)
		$Sounds/GrassFootstep.play()
