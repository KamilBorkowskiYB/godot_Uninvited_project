extends CharacterBody2D


@export var move_speed = 100
@onready var viewRayCast = $ViewRayCast
var dead = false
@export var push_force = 10.0
var move_direction = Vector2(0,0)
var standing_on :String = "grass"
var floor_move_speed_debuff = 1.0


func _ready():
	$Graphic/Body/Head/HurtBoxArea.got_hit_head.connect(head_hit)
	$Graphic/Body/RightShoulder/RightElbow/HurtBoxArea.got_hit_head.connect(right_arm_hit)
	$Graphic/Body/RightShoulder/HurtBoxArea.got_hit_head.connect(right_arm_hit)
	
	$Graphic/Body/LeftShoulder/LeftElbow/HurtBoxArea.got_hit_head.connect(left_arm_hit)
	$Graphic/Body/LeftShoulder/HurtBoxArea.got_hit_head.connect(left_arm_hit)
	
	$Graphic/Body/RightFrontShoulder/RightFrontElbow/HurtBoxArea.got_hit_head.connect(front_right_arm_hit)
	$Graphic/Body/RightFrontShoulder/HurtBoxArea.got_hit_head.connect(front_right_arm_hit)
	
	$Graphic/Body/LeftFrontShoulder/LeftFrontElbow/HurtBoxArea.got_hit_head.connect(front_left_arm_hit)
	$Graphic/Body/LeftFrontShoulder/HurtBoxArea.got_hit_head.connect(front_left_arm_hit)
	

func _physics_process(_delta):
	if dead:
		return
	if standing_on == "water":
		floor_move_speed_debuff = 0.3
	else:
		floor_move_speed_debuff = 1.0
	
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player:
		viewRayCast.target_position = player.global_position - viewRayCast.global_position
	
	if  player in $ViewArea.get_overlapping_bodies() and viewRayCast.get_collider() == player:
		player_spoted()
	else:
		player_lost()
		
	#move_direction = global_position.direction_to(player.global_position)
	#velocity = move_speed * move_direction * floor_move_speed_debuff
	#move_and_slide()
	#for i in get_slide_collision_count():
		#var c = get_slide_collision(i)
		#if c.get_collider() is RigidBody2D:
			#c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	
	#global_rotation = move_direction.angle() + PI/2.0
	

func player_spoted():
	$AnimationFrontArms.play("Chase")
	$AnimationLeftArm.play("Chase")
	$AnimationRightArm.play("Chase")

func player_lost():
		$AnimationFrontArms.play("Idle")
		$AnimationFrontArms.speed_scale = 2.5
		$AnimationLeftArm.play("Idle")
		$AnimationLeftArm.speed_scale = 2.5
		$AnimationRightArm.play("Idle")

func kill(attack: Attack):
	if dead:
		return
	print("hit")

func head_hit(attack: Attack):
	if dead:
		return
	print("critical hit")

func right_arm_hit(attack: Attack):
	if dead:
		return
	$Graphic/Body/RightShoulder/RightUpper.hide()
	$Graphic/Body/RightShoulder/RightElbow/RightLower.hide()
	$Graphic/Body/RightShoulder/RightElbow/RightClawL.hide()
	$Graphic/Body/RightShoulder/RightElbow/RightClawM.hide()
	$Graphic/Body/RightShoulder/RightElbow/RightClawR.hide()
	$Graphic/Body/RightShoulder/RightElbow/HurtBoxArea.hide()
	$Graphic/Body/RightShoulder/RightElbow/HurtBoxArea/CollisionShape2D.disabled = true
	$Graphic/Body/RightShoulder/HurtBoxArea.hide()
	$Graphic/Body/RightShoulder/HurtBoxArea/CollisionShape2D.disabled = true
	$Graphic/Body/RightShoulder/Blood.emitting = true
	
	$Graphic/Body/RightShoulder/ShoulderDestroyed.emitting = true
	$Graphic/Body/RightShoulder/RightElbow/ElbowDestroyed.emitting = true
	
	$Graphic/Body/RightShoulder/Blood/Timer.start()
	print("right arm hit")


func left_arm_hit(attack: Attack):
	if dead:
		return
	$Graphic/Body/LeftShoulder/LeftUpper.hide()
	$Graphic/Body/LeftShoulder/LeftElbow/LeftLower.hide()
	$Graphic/Body/LeftShoulder/LeftElbow/LeftClawL.hide()
	$Graphic/Body/LeftShoulder/LeftElbow/LeftClawR.hide()
	$Graphic/Body/LeftShoulder/LeftElbow/HurtBoxArea.hide()
	$Graphic/Body/LeftShoulder/LeftElbow/HurtBoxArea/CollisionShape2D.disabled = true
	$Graphic/Body/LeftShoulder/HurtBoxArea/CollisionShape2D.disabled = true
	$Graphic/Body/LeftShoulder/Blood.emitting = true
	
	$Graphic/Body/LeftShoulder/ShoulderDestroyed.emitting = true
	$Graphic/Body/LeftShoulder/LeftElbow/ElbowDestroyed.emitting = true
	
	$Graphic/Body/LeftShoulder/Blood/Timer.start()
	print("left arm hit")
	
func front_right_arm_hit(attack: Attack):
	if dead:
		return
	$Graphic/Body/RightFrontShoulder/RightFrontUpper.hide()
	$Graphic/Body/RightFrontShoulder/RightFrontElbow/RightFrontLower.hide()
	$Graphic/Body/RightFrontShoulder/RightFrontElbow/RightFrontClawL.hide()
	$Graphic/Body/RightFrontShoulder/RightFrontElbow/RightFrontClawR.hide()
	$Graphic/Body/RightFrontShoulder/RightFrontElbow/HurtBoxArea.hide()
	$Graphic/Body/RightFrontShoulder/RightFrontElbow/HurtBoxArea/CollisionShape2D.disabled = true
	$Graphic/Body/RightFrontShoulder/HurtBoxArea/CollisionShape2D.disabled = true
	$Graphic/Body/RightFrontShoulder/Blood.emitting = true
	
	$Graphic/Body/RightFrontShoulder/ShoulderDestroyed.emitting = true
	
	$Graphic/Body/RightFrontShoulder/Blood/Timer.start()
	print("right low arm hit")
	

func front_left_arm_hit(attack: Attack):
	if dead:
		return
	$Graphic/Body/LeftFrontShoulder/LeftFrontUpper.hide()
	$Graphic/Body/LeftFrontShoulder/LeftFrontElbow/LeftFrontLower.hide()
	$Graphic/Body/LeftFrontShoulder/LeftFrontElbow/LeftFrontClawL.hide()
	$Graphic/Body/LeftFrontShoulder/LeftFrontElbow/LeftFrontClawR.hide()
	$Graphic/Body/LeftFrontShoulder/LeftFrontElbow/HurtBoxArea.hide()
	$Graphic/Body/LeftFrontShoulder/LeftFrontElbow/HurtBoxArea/CollisionShape2D.disabled = true
	$Graphic/Body/LeftFrontShoulder/HurtBoxArea/CollisionShape2D.disabled = true
	$Graphic/Body/LeftFrontShoulder/Blood.emitting = true
	
	$Graphic/Body/LeftFrontShoulder/ShoulderDestroyed.emitting = true
	
	$Graphic/Body/LeftFrontShoulder/Blood/Timer.start()
	print("left low arm hit")

func step():
	pass
	#if standing_on == "brick":
		#$ConcreteFootstep.pitch_scale = randf_range(0.8, 1.2)
		#$ConcreteFootstep.play()
	#if standing_on == "grass":
		#$GrassFootstep.pitch_scale = randf_range(0.8, 1.2)
		#$GrassFootstep.play()

