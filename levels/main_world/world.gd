extends Node2D

#@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _ready():
	var viewport1 = get_node("MainLevelViewport/SubViewport")
	var viewport2 = get_node("FogViewport")
	var viewport3 = get_node("VisibilityViewport")
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	#setting viewports size to match project size
	var view_size = get_viewport().get_visible_rect().size
	viewport1.size = view_size
	viewport2.size = view_size
	viewport3.size = view_size
	
	viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0)
	#connecting viewport cameras
	var cam_main = viewport1.get_node_or_null("PlayerCamera")
	var cam_fog = viewport2.get_node_or_null("Camera2D")
	var cam_view = viewport3.get_node_or_null("Camera2D")
	if(cam_main and cam_fog and cam_view):
		cam_main.vision_camera = cam_view
		cam_main.fog_camera = cam_fog
	
	#connecting VisionViewport lights to player
	var view_light = viewport3.get_node_or_null("ViewLight")
	if(player and view_light):
		player.view_light = view_light
	
	
	#connecting tilemap to player footsteps
	var tilemap = null
	if viewport1.get_child(0).get_child(0).get_node("Tilemap").get_child_count() > 0:
		tilemap = viewport1.get_child(0).get_child(0).get_node("Tilemap").get_child(0)
	var footnode = player.get_node("Footsteps")
	if(footnode and tilemap):
		footnode.tilemap = tilemap
	
	#connecting tilemap to zombies footsteps
	viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0).get_node("Enemies")
	for child in viewport1.get_children():
		if(child and tilemap):
			child.get_node_or_null("Footsteps").tilemap = tilemap
	
	
	#connecting aim assist to player 
	var aim = $WeaponSelected/AimAssist
	var aimL = $WeaponSelected/AimAssist/AimAssistL
	var aimR = $WeaponSelected/AimAssist/AimAssistR
	if(player and aim and aimL and aimR):
		player.aim_assist = aim
		player.aim_assistR = aimR
		player.aim_assistL = aimL
	
	#connecting signals from player
	player.player_has_died.connect(player_dead)
	player.weapon_info_on.connect(weapon_info_visible)
	
	#connecting signals from pickUps
	viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0).get_node("PickUps")
	for child in viewport1.get_children():
		if child.has_signal("item_picked_up"):
			child.item_picked_up.connect(item_picked_up)
	
	#connecting signals from LevelExits
	viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0).get_node("LevelExits")
	for child in viewport1.get_children():
		if child.has_signal("change_level"):
			child.change_level.connect(change_level)
	
	#setting materials in viewport3 to white
	change_material_to_white(viewport3.get_child(0))
	
	viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0).get_child(0).get_child(0).get_node("Doors")
	viewport2 = get_node("FogViewport").get_child(0).get_child(0).get_node("Doors")
	viewport3 = get_node("VisibilityViewport").get_child(0).get_node("Doors")
	
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
	
	viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0).get_child(0).get_child(0).get_node("MovingBlocks")
	viewport2 = get_node("FogViewport").get_child(0).get_child(0).get_node("MovingBlocks")
	viewport3 = get_node("VisibilityViewport").get_child(0).get_node("MovingBlocks")
	
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

func _process(_delta):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player != null:
		$WeaponSelected/Control/Label.text = str(player.magazine) +"/"+ str(player.ammo)
	if Input.is_action_just_pressed("restart"):
		restart()
func restart():
	get_tree().reload_current_scene()
func player_dead():
	$DeathScreen/DeathScreen.show()
func item_picked_up(is_space,item_name):
	if is_space == 1:
		$ItemsObtained/UI/Panel/Label.text = "Acquired: " + item_name
	else:
		$ItemsObtained/UI/Panel/Label.text = "No more space: " + item_name
	$ItemsObtained/UI.show()
	$ItemsObtained/UI/PickUpTimer.start()
func weapon_info_visible():
	$WeaponSelected/Control.show()
func change_material_to_white(node):
	node.use_parent_material = true
	for child in node.get_children():
		change_material_to_white(child)
func change_level(player_pos,level_high,level_mid,level_low):
	get_node("MainLevelViewport/SubViewport").get_child(0).queue_free()
	get_node("FogViewport").get_child(0).queue_free()
	get_node("VisibilityViewport").get_child(0).queue_free()
	
	var viewport1 = get_node("MainLevelViewport/SubViewport")
	var viewport2 = get_node("FogViewport")
	var viewport3 = get_node("VisibilityViewport")
	
	var instance_high = load(level_high).instantiate()
	var instance_mid = load(level_mid).instantiate()
	var instance_low = load(level_low).instantiate()
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://shaders/visibilityMapShader.gdshader")
	instance_low.material = shader_material
	
	viewport1.add_child(instance_high)
	viewport2.add_child(instance_mid)
	viewport3.add_child(instance_low)
	
	viewport1.move_child(instance_high,0)
	viewport2.move_child(instance_mid,0)
	viewport3.move_child(instance_low,0)
	
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	player.position = player_pos
	_ready()
	InteractionManager.active_areas = []
	InteractionManager.mouse_range = []
