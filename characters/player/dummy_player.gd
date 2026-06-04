extends CharacterBody2D

##########        PLAYER NODES        ##########
@onready var top = $Top
@onready var bottom = $Bottom
@onready var legs = $Bottom/Legs
@onready var animation_player = $AnimationPlayerTOP
@onready var animation_playerLegs = $AnimationPlayerLEGS
@onready var animation_run_rotation = $AnimationPlayerRUNROT
@onready var bullet_trail = load("res://characters/player/misc/shot_trail.tscn")

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	player.shot_fired.connect(shoot)


func _process(_delta):
	var player_help = get_tree().get_first_node_in_group("player")
	top.rotation = player_help.top.rotation
	position = player_help.position
	
	sync_animation(animation_player, player_help.animation_player)
	sync_animation(animation_playerLegs, player_help.animation_playerLegs)
	sync_animation(animation_run_rotation, player_help.animation_run_rotation)


func sync_animation(local_anim: AnimationPlayer, target_anim: AnimationPlayer):
	if !target_anim.is_playing():
		if local_anim.is_playing():
			local_anim.stop()
		return

	var current = target_anim.current_animation
	if current == "":
		return
	# animation changed
	if local_anim.current_animation != current:
		local_anim.play(current)
	# sync playback position
	local_anim.seek(
		target_anim.current_animation_position,
		true
	)


func shoot(shots_data):
	var space_state = get_world_2d().direct_space_state
	var level = get_parent().get_child(0)
	
	for shot in shots_data:
		var origin = shot.start
		var end = shot.end
		var direction = (end - origin).normalized()
		var length = shot.length
		var damage = shot.damage
		
		# REAL raycast in dummy world
		var query = PhysicsRayQueryParameters2D.create(origin, origin + direction * length)
		var result = space_state.intersect_ray(query)
		var end_point = origin + direction * length
		if !result.is_empty():
			end_point = result.position
		
		# TRAIL
		var shot_trail = bullet_trail.instantiate()
		shot_trail.add_point(level.to_local(origin))
		shot_trail.add_point(level.to_local(end_point))
		level.add_child(shot_trail)
		
		# DAMAGE
		if !result.is_empty():
			var collider = result.collider
			if collider and collider.has_method("kill"):
				var attack = Attack.new()
				attack.attack_damage = damage
				attack.attack_direction = -direction
				collider.kill(attack)
