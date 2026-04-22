extends CharacterBody2D

signal player_has_died
signal weapon_info_on

var view_light: Node2D #Connects view with player
var dim_split_light: Node2D
var od_view_light: Node2D
var aim_assist: Node2D 
var aim_assistR: Node2D 
var aim_assistL: Node2D 

##########        CURSORS        ##########
@onready var cursor_interact = load("res://cursor/cursor_interact.png")
@onready var cursor_aim = load("res://cursor/cursor_aim.png")
@onready var cursor_normal = load("res://cursor/cursor_normal.png")
var cursor_current = null

##########        FOOTSTEPS        ##########
var standing_on :String = "grass"

##########        PICK UPS        ##########
var pistol_unlock = 1
var rifle_unlock = 1 #remember to update pickUp.gd with every new pick up
var shotgun_unlock = 0 #ammo has special case for pickups

##########        PLAYER NODES        ##########
@onready var top = $Top
#@onready var player_top_sprite = $Top/Alive
@onready var player_top_sprite = $Top/Alive_New
@onready var bottom = $Bottom #rotates legs with top offset - like in aiming moves to the side
@onready var legs = $Bottom/Legs #rotates legs in the direction of the walking
@onready var ray_cast1 = top.get_node("RayCasts/RayCast2D")
@onready var ray_cast2 = top.get_node("RayCasts/RayCast2D2")
@onready var ray_cast3 = top.get_node("RayCasts/RayCast2D3")
@onready var ray_cast4 = top.get_node("RayCasts/RayCast2D4")
@onready var animation_player = $AnimationPlayerTOP
@onready var animation_playerLegs = $AnimationPlayerLEGS
@onready var animation_run_rotation = $AnimationPlayerRUNROT
@onready var bullet_trail = load("res://characters/player/misc/shot_trail.tscn")
@export var move_speed = 200
var aim_move_speed_debuff = 1.0
var floor_move_speed_debuff = 1.0
var run_move_speed_buff = 1.0
var animation_walk = "walking"
@export var push_force = 20.0
var dead = false
var grabbing = false
var grabbed_object:RigidBody2D
@export var can_shoot = false
@export var can_interact = true #not used at the moment
var move_direction = Vector2(0,0)

##########        WEAPON STATS         ##########
var WEAPONS = {
	"pistol": {
		"frame": 13,
		"weapon_number": 2,
		"max_recoil": 50.0,
		"min_recoil": 5.0,
		"min_recoil_walking": 20.0,
		"focus_speed": 15.0,
		"damage": 10.0,
		"mag_size": 8,
		"current_magazine": 8,
		"max_ammo": 24,
		"current_ammo": 8,
		"raycast_offset": -75,
		"anims": {
			"aim": "aim_pistol",
			"aimed": "aimed_pistol",
			"reload": "reload_pistol",
			"idle": "idle_pistol",
			"aftershot": "aftershot_pistol"
		}
	},
	"rifle": {
		"frame": 39,
		"weapon_number": 0,
		"max_recoil": 30.0,
		"min_recoil": 1.0,
		"min_recoil_walking": 10.0,
		"focus_speed": 20.0,
		"damage": 30.0,
		"mag_size": 1,
		"current_magazine": 1,
		"max_ammo": 10,
		"current_ammo": 1,
		"raycast_offset": -115,
		"anims": {
			"aim": "aim_rifle",
			"aimed": "aimed_rifle",
			"reload": "reload_rifle",
			"idle": "idle_rifle",
			"aftershot": "aftershot_rifle"
		}
	},
	"shotgun": {
		"frame": 52,
		"weapon_number": 1,
		"max_recoil": 60.0,
		"min_recoil": 10.0,
		"min_recoil_walking": 35.0,
		"focus_speed": 20.0,
		"damage": 15.0,
		"mag_size": 5,
		"current_magazine": 2,
		"max_ammo": 15,
		"current_ammo": 2,
		"raycast_offset": -115,
		"anims": {
			"aim": "aim_shotgun",
			"aimed": "aimed_shotgun",
			"reload": "reload_shotgun_calm",
			"idle": "idle_shotgun",
			"aftershot": "aftershot_shotgun"
		}
	},
	"default": {
		"frame": 0,
		"weapon_number": null,
		"max_recoil": 0.0,
		"min_recoil": 0.0,
		"min_recoil_walking": 0.0,
		"focus_speed": 0.0,
		"damage": 0.0,
		"mag_size": 0,
		"current_magazine": 0,
		"max_ammo": 0,
		"current_ammo": 0,
		"anims": {
			"aim": "aim_shotgun",
			"aimed": "aimed_shotgun",
			"reload": "reload_shotgun_calm",
			"idle": "idle_unarmed",
			"aftershot": "aftershot_shotgun"
		}
	}
}
#defalut
var current_weapon_id = "default"
var current_weapon = WEAPONS[current_weapon_id]
var max_recoil = current_weapon["max_recoil"]
var min_recoil = current_weapon["min_recoil"]#dynamic min recoil based of walking, etc.
var min_recoil_walking = current_weapon["min_recoil_walking"]#static min recoil based on movement and weapon 
var recoil = current_weapon["max_recoil"] * 0.7
var recoil_focus_speed = (current_weapon["max_recoil"]-current_weapon["min_recoil"])/current_weapon["focus_speed"]
var floor_min_recoil = current_weapon["min_recoil"] #static min recoil based on weapon ()
var damage = current_weapon["damage"]
var animation_idle = "idle_unarmed"
var animations = current_weapon["anims"]
var animation_aim = animations["aim"]
var animation_aimed = animations["aimed"]
var animation_reload = animations["reload"]
var animation_aftershot = animations["aftershot"]

func _ready():
	can_shoot = false
	can_interact = true
	animation_player.play("idle_unarmed")

func _process(delta):
	##########        CONNECTING NODES FROM VIEWPORTS         ##########
	if aim_assist != null:
		#aim_assist.position = self.position
		#position is set in camera_control.gd
		aim_assist.rotation = top.rotation
		
	if view_light != null:      #viewPorty
		view_light.rotation = top.rotation
		view_light.position = self.position
	if dim_split_light != null and od_view_light != null:
		dim_split_light.rotation = top.rotation
		dim_split_light.position = self.position
		od_view_light.rotation = top.rotation
		od_view_light.position = self.position
	##########        EXITING         ##########
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	##########        IF DEAD DO NOTHING         ##########
	if dead:
		return
		
	##########        TOP AND LEGS ROTATION         ##########
	if !grabbing:
		top.rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI/2
	else:
		var target_rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI/2
		top.rotation = lerp_angle(top.rotation, target_rotation, 0.01 / grabbed_object.mass)
	move_direction = Input.get_vector("move_left","move_right","move_down","move_up")
	legs.rotation = move_direction.angle() + PI/2 - bottom.rotation
	bottom.rotation = top.rotation
	
	if velocity.length() > 0:
		animation_playerLegs.play(animation_walk)
		min_recoil = min_recoil_walking
		if(recoil < min_recoil):
			recoil = min_recoil
	else:
		animation_playerLegs.stop()
		min_recoil = floor_min_recoil
	
	##########        INPUTS         ##########
	if Input.is_action_pressed("run"):
		if grabbing:
			return
		if cursor_current == cursor_aim or velocity.length() <= 0:
			run_move_speed_buff = 1.0
			animation_playerLegs.speed_scale = 1.0
			animation_run_rotation.stop()
		elif velocity.length() > 0:
			run_move_speed_buff = 1.7
			animation_playerLegs.speed_scale = 1.5
			animation_run_rotation.play("run_rotate")
	
	if Input.is_action_just_released("run"):
		stop_run()
	
	if Input.is_action_just_pressed("shoot"):
		if current_weapon["current_magazine"] <= 0:
			return
		elif current_weapon_id == "shotgun":
			current_weapon["current_magazine"] = shoot([ray_cast1,ray_cast2,ray_cast3,ray_cast4],current_weapon["current_magazine"])
		else:
			current_weapon["current_magazine"] = shoot([ray_cast1], current_weapon["current_magazine"])
	
	if Input.is_action_just_pressed("weapon_1"):
		if rifle_unlock > 0 and !grabbing and current_weapon_id != "rifle":
			change_weapon("rifle")
			weapon_info_on.emit()
			
	if Input.is_action_just_pressed("weapon_2"):
		if shotgun_unlock > 0 and !grabbing and current_weapon_id != "shotgun":
			change_weapon("shotgun")
			weapon_info_on.emit()
	
	if Input.is_action_just_pressed("weapon_3"):
		if pistol_unlock > 0 and !grabbing  and current_weapon_id != "pistol":
			change_weapon("pistol")
			weapon_info_on.emit()
	
	if Input.is_action_just_pressed("Aim"):
		aim()
	
	if Input.is_action_pressed("Aim") and cursor_current == cursor_aim:
		if current_weapon_id == "default" or grabbing:
			return
		recoil = lerp(recoil, min_recoil, recoil_focus_speed * delta)
		
		if recoil != 0:
			ray_cast1.rotation_degrees = randf_range(-recoil, recoil)
			ray_cast2.rotation_degrees= randf_range(-recoil, recoil)
			ray_cast3.rotation_degrees= randf_range(-recoil, recoil)
			ray_cast4.rotation_degrees = randf_range(-recoil, recoil)
	else:
		recoil = lerp(recoil, max_recoil, recoil_focus_speed * delta)
	aim_assistR.rotation_degrees = recoil
	aim_assistL.rotation_degrees = -recoil
	
	if Input.is_action_just_released("Aim"):
		unaim()
	
	if Input.is_action_just_pressed("reload"):
		if current_weapon["current_magazine"] == current_weapon["mag_size"] or current_weapon["current_ammo"] == 0 or current_weapon["weapon_number"] == null:
			return
		if current_weapon_id == "rifle":
			if cursor_current == cursor_aim and can_shoot:
				animation_player.play(animation_reload)
				#animation_player.queue(animation_aimed)
			else:# rifle can reload without aiming
				animation_player.play("reload_rifle_calm")
		else:
			unaim()
			animation_player.queue(animation_reload)


func _physics_process(_delta):
	if dead:
		return
	##########        MOVING         ##########
	var move_dir = Input.get_vector("move_left","move_right","move_down","move_up")
	velocity = move_dir * move_speed * aim_move_speed_debuff * floor_move_speed_debuff * run_move_speed_buff
	if grabbing:
		velocity = velocity / grabbed_object.mass
	move_and_slide()
	if standing_on == "water":
		floor_move_speed_debuff = 0.3
		legs.hide()
		$WaterSplash.emitting = true
	else:
		floor_move_speed_debuff = 1.0
		legs.show()
		$WaterSplash.emitting = false
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
	top.get_node("Dead").show()
	player_top_sprite.hide()
	legs.hide()
	z_index = -1
	emit_signal("player_has_died")

func shoot(ray_casts,ammo_type):
	if can_shoot == true:
		animation_player.play(animation_aftershot)
		#the following should be in the animation
		top.get_node("MuzzleFlash").show()
		top.get_node("FlashLight").show()
		top.get_node("MuzzleFlash/Timer").start()
		$Sounds/ShootSound.play()
		
		var level = get_parent().get_child(0) #level always should be first node of viewport
		level.start_shake(10, 0.1) 
		recoil = min(max_recoil, recoil + max_recoil * 0.7)
		ammo_type -= 1
		# Iterate through all RayCast2D
		for ray_cast in ray_casts:
			var direction = ray_cast.global_position - get_global_mouse_position() # where player looks, not where raycast shoots
			direction = direction.normalized()
			var offset = direction * current_weapon["raycast_offset"]
			var shoot_dir = (ray_cast.to_global(ray_cast.target_position) - ray_cast.to_global(Vector2.ZERO)).normalized()
			
			var shot_trail = bullet_trail.instantiate()
			
			# Setting bullet trail points
			shot_trail.add_point(level.to_local(ray_cast.global_position) + offset)
			if ray_cast.is_colliding():
				shot_trail.add_point(level.to_local(ray_cast.get_collision_point()))
			else:
				var end_point = ray_cast.global_position + shoot_dir * 2000.0
				shot_trail.add_point(level.to_local(end_point))
			level.add_child(shot_trail)
			
			# Killing
			if ray_cast.is_colliding():
				if ray_cast.get_collider().has_method("kill"):
					var attack = Attack.new()
					attack.attack_damage = damage
					attack.attack_direction = direction
					ray_cast.get_collider().kill(attack)
	return ammo_type

func aim():
	if current_weapon_id == "default" or grabbing:
		return
	animation_player.play(animation_aim)
	#animation_player.queue(animation_aimed)
	animation_playerLegs.speed_scale = 0.7
	aim_move_speed_debuff = 0.5
	aim_assistR.show()
	aim_assistL.show()
	Input.set_custom_mouse_cursor(cursor_aim,Input.CURSOR_ARROW,Vector2(24,24))
	cursor_current = cursor_aim

func unaim():
	if current_weapon_id == "default":
		return
	if cursor_current == cursor_aim:
		animation_player.play_backwards(animation_aim)
		animation_playerLegs.speed_scale = 1
		aim_move_speed_debuff = 1
		aim_assistR.hide()
		aim_assistL.hide()
		Input.set_custom_mouse_cursor(cursor_normal,Input.CURSOR_ARROW,Vector2(24,24))
		cursor_current = cursor_normal

func animation_end_reload():
	if current_weapon["current_magazine"] < current_weapon["mag_size"] and current_weapon["current_ammo"] > 0:
		var resoult = reload(current_weapon["current_magazine"],current_weapon["mag_size"],current_weapon["current_ammo"])
		current_weapon["current_magazine"] = resoult[0]
		current_weapon["current_ammo"] = resoult[1]
		if current_weapon_id == "shotgun":
			shotgun_load_shell()
		elif current_weapon_id == "pistol":
			if Input.is_action_pressed("Aim"):
				aim()

func reload(curr_mag,mag_size,amo):
	var needed_ammo = mag_size - curr_mag
	if current_weapon_id == "shotgun":
		needed_ammo = 1
	var ammo_taken
	if needed_ammo <= amo:
		ammo_taken = needed_ammo
	else:
		ammo_taken = amo
	curr_mag = curr_mag + ammo_taken
	amo = amo - ammo_taken
	return [curr_mag, amo]

func shotgun_load_shell():
	if current_weapon["current_magazine"] < current_weapon["mag_size"] and current_weapon["current_ammo"] > 0:
		animation_player.queue("reload_shotgun_next")
	elif Input.is_action_pressed("Aim"):
		aim()
	else:
		animation_player.play("reload_shotgun_end")


func change_weapon(id):
	if cursor_current != cursor_aim and !animation_player.is_playing():
		var w = WEAPONS[id]
		current_weapon_id = id
		current_weapon = w
		
		max_recoil = w["max_recoil"]
		min_recoil = w["min_recoil"]
		floor_min_recoil = w["min_recoil"]
		min_recoil_walking = w["min_recoil_walking"]
		damage = w["damage"]
		recoil_focus_speed = (w["max_recoil"] - w["min_recoil"]) / w["focus_speed"]
		recoil = w["max_recoil"] * 0.7
		
		animation_idle = w["anims"]["idle"]
		animation_aim = w["anims"]["aim"]
		animation_aimed = w["anims"]["aimed"]
		animation_reload = w["anims"]["reload"]
		animation_aftershot = w["anims"]["aftershot"]
		animation_player.play(animation_idle)


func grab_object(object: RigidBody2D):
	grabbing = true
	stop_run()
	animation_player.play("grabbing")
	grabbed_object = object

func realese_object():
	grabbing = false
	grabbed_object = null
	animation_player.play(current_weapon["anims"]["idle"])

func stop_run():
	run_move_speed_buff = 1.0
	animation_playerLegs.speed_scale = 1.0
	animation_run_rotation.stop()
	if animation_player.current_animation == "run_unarmed":#No such anim for a moment
		animation_player.stop()
		player_top_sprite.frame = 0;

func step():
	if standing_on == "brick":
		$Sounds/ConcreteFootstep.pitch_scale = randf_range(0.8, 1.2)
		$Sounds/ConcreteFootstep.play()
	if standing_on == "grass":
		$Sounds/GrassFootstep.pitch_scale = randf_range(0.8, 1.2)
		$Sounds/GrassFootstep.play()
