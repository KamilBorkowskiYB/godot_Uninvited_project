extends Node2D


func _ready():
	var viewport1 = get_node("MainLevelViewport/SubViewport/Level")
	var viewport2 = get_node("FogViewport")
	var viewport3 = get_node("VisibilityViewport")
	
	#connecting viewport cameras
	var cam_main = viewport1.get_node_or_null("PlayerCamera")
	var cam_fog = viewport2.get_node_or_null("Camera2D")
	var cam_view = viewport3.get_node_or_null("Camera2D")
	if(cam_main and cam_fog and cam_view):
		cam_main.vision_camera = cam_view
		cam_main.fog_camera = cam_fog
	
	#connecting VisionViewport lights to player
	var player = viewport1.get_node_or_null("Player")
	var view_light = viewport3.get_node_or_null("ViewLight")
	if(player and view_light):
		player.view_light = view_light
	
	
	#connecting aim assist to player 
	var aim = viewport2.get_node_or_null("AimAssist")
	var aimL = viewport2.get_node_or_null("AimAssist/AimAssistL")
	var aimR = viewport2.get_node_or_null("AimAssist/AimAssistR")
	if(player and aim and aimL and aimR):
		player.aim_assist = aim
		player.aim_assistR = aimR
		player.aim_assistL = aimL
	
	#connecting signals from player
	player.player_has_died.connect(player_dead)
	
	viewport1 = get_node("MainLevelViewport/SubViewport/Level/Enviroment")
	viewport2 = get_node("FogViewport/Enviroment")
	viewport3 = get_node("VisibilityViewport/Enviroment")
	
	for i in range(4):#connecting doors
		if(i==0):
			var node1 = viewport1.get_node_or_null("Door")
			var node2 = viewport2.get_node_or_null("Door")
			var node3 = viewport3.get_node_or_null("Door")
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
		else:
			var node1 = viewport1.get_node_or_null("Door" + str(i))
			var node2 = viewport2.get_node_or_null("Door" + str(i))
			var node3 = viewport3.get_node_or_null("Door" + str(i))
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
	
	for i in range(4):#connecting Moving block
		if(i==0):
			var node1 = viewport1.get_node_or_null("MovingBlock")
			var node2 = viewport2.get_node_or_null("MovingBlock")
			var node3 = viewport3.get_node_or_null("MovingBlock")
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
		else:
			var node1 = viewport1.get_node_or_null("MovingBlock" + str(i))
			var node2 = viewport2.get_node_or_null("MovingBlock" + str(i))
			var node3 = viewport3.get_node_or_null("MovingBlock" + str(i))
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
	
	for i in range(4):#connecting lowMoving block
		if(i==0):
			var node1 = viewport1.get_node_or_null("lowMovingBlock")
			var node2 = viewport2.get_node_or_null("lowMovingBlock")
			var node3 = viewport3.get_node_or_null("lowMovingBlock")
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
		else:
			var node1 = viewport1.get_node_or_null("lowMovingBlock" + str(i))
			var node2 = viewport2.get_node_or_null("lowMovingBlock" + str(i))
			var node3 = viewport3.get_node_or_null("lowMovingBlock" + str(i))
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		restart()
func restart():
	get_tree().reload_current_scene()
func player_dead():
	$DeathScreen/DeathScreen.show()
