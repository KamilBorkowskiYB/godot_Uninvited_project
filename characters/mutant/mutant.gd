extends CharacterBody2D


@export var move_speed = 100
var dead = false
@export var push_force = 10.0
var move_direction = Vector2(0,0)
var standing_on :String = "grass"
var floor_move_speed_debuff = 1.0

func _ready():
	$Graphic/Body/Head/HurtBoxArea.got_hit_head.connect(head_hit)
	$Graphic/Body/RightShoulder/RightUpper/RightElbow/HurtBoxArea.got_hit_head.connect(arm_hit)
	
func _physics_process(_delta):
	if dead:
		return
	if standing_on == "water":
		floor_move_speed_debuff = 0.3
	else:
		floor_move_speed_debuff = 1.0

	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	#move_direction = global_position.direction_to(player.global_position)
	#velocity = move_speed * move_direction * floor_move_speed_debuff
	#move_and_slide()
	#for i in get_slide_collision_count():
		#var c = get_slide_collision(i)
		#if c.get_collider() is RigidBody2D:
			#c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	
	#global_rotation = move_direction.angle() + PI/2.0
	
		
func kill(attack: Attack):
	if dead:
		return
	print("hit")

func head_hit(attack: Attack):
	if dead:
		return
	print("critical hit")

func arm_hit(attack: Attack):
	if dead:
		return
	#$Graphic/Body/RightShoulder/RightUpper/RightElbow.hide()
	$Graphic/Body/RightShoulder/RightUpper/RightElbow/RightLower.hide()
	$Graphic/Body/RightShoulder/RightUpper/RightElbow/RightClaw.hide()
	$Graphic/Body/RightShoulder/RightUpper/RightElbow/HurtBoxArea.hide()
	$Graphic/Body/RightShoulder/RightUpper/RightElbow/HurtBoxArea/CollisionShape2D.disabled = true
	$Graphic/Body/RightShoulder/RightUpper/Blood.emitting = true
	
	$Graphic/Body/RightShoulder/RightUpper/RightElbow/ElbowDestroyed.emitting = true
	print("arm hit")
	
func step():
	pass
	#if standing_on == "brick":
		#$ConcreteFootstep.pitch_scale = randf_range(0.8, 1.2)
		#$ConcreteFootstep.play()
	#if standing_on == "grass":
		#$GrassFootstep.pitch_scale = randf_range(0.8, 1.2)
		#$GrassFootstep.play()

