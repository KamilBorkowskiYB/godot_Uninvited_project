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
	
	#connecting tilemap to enemies footsteps
	viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0).get_node("Enemies")
	for child in viewport1.get_children():
		if(child and tilemap):
			child.get_node_or_null("Footsteps").tilemap = tilemap
	
	#connecting tilemap to movingblocks
	viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0).get_child(0).get_child(0).get_node("MovingBlocks") #First get_child - lvl_hight, second - lvl_middium, third - lvl_low
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
	if not player.player_has_died.is_connected(player_dead):#conneting connected singnal returns error
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
	
	#connecting signals from Secrets
	viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0).get_child(0).get_node("Secrets")
	for child in viewport1.get_children():
		if child.get_child(0).has_signal("reveal_area"):
			child.get_child(0).reveal_area.connect(reveal_area)
	
	#setting materials in viewport3 to white
	change_material_to_white(viewport3.get_child(0))
	
	
	# Connecting movable blocks and doors
	viewport1 = get_node("MainLevelViewport/SubViewport")
	viewport2 = get_node("FogViewport")
	viewport3 = get_node("VisibilityViewport")
	var all_movable = get_tree().get_nodes_in_group("movable_blocks")
	
	for node1 in all_movable:
		if not viewport1.is_ancestor_of(node1):
			continue
		
		var target_name = node1.name
		var node2 = null
		var node3 = null
		
		for candidate in all_movable:
			if candidate.name == target_name and viewport2.is_ancestor_of(candidate):
				node2 = candidate
				break
		for candidate in all_movable:
			if candidate.name == target_name and viewport3.is_ancestor_of(candidate):
				node3 = candidate
				break
		
		if node2 and node3:
			node1.linkedView = node2
			node1.linkedFog = node3
		
		#Connecting doors with hiden areas
		var ha1 = node1.get("hidden_area_name")
		if ha1 != null and ha1 != "": 
			node1.hidden_area = get_node("MainLevelViewport/SubViewport").get_child(0).get_child(0).get_node(node1.hidden_area_name)
		
		node1.remove_from_group("movable_blocks")
	
	# Hidding front elements in Visibility Viewport
	var transparent = get_tree().get_nodes_in_group("Transparent")
	for node in transparent:
		if viewport3.is_ancestor_of(node):
			node.hide()
				# Disabling transparency in FogViewport
		if viewport2.is_ancestor_of(node):
			var mat: Material = node.material
			if mat and mat is ShaderMaterial:
				mat.set_shader_parameter("fog_dont_show", true)
	viewport1.get_child(0)._ready() # reloads transparency calculation on level change


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


func reveal_area(secret_name: String):
	#TILESET MUST BE NAMED JUST LIKE SECRET 
	var viewport1 = get_node("MainLevelViewport/SubViewport").get_child(0).get_child(0).get_node("Secrets")
	var viewport2 = get_node("FogViewport").get_child(0).get_node("out_of_view_overlay").get_node("SecretsColor") #lights secrets   #get_node("FogViewport").get_child(0).get_child(0).get_node("Secrets")
	var viewport2prim = get_node("FogViewport").get_child(0).get_node("out_of_view_overlay").get_node("SecretsModulate") #tileset and other overlay
	
	var node1 = viewport1.get_node(NodePath(secret_name))
	var node2 = viewport2.get_node(NodePath(secret_name))
	var node3 = viewport2prim.get_node_or_null(NodePath(secret_name))
	
	var tween_timer: float = 0.4
	var tween1 = create_tween()
	tween1.tween_property(node1, "color:a", 0.0, tween_timer) 
	tween1.tween_callback(func(): node1.queue_free())
	
	if node2: #light node in gray_viewport
		var tween2 = create_tween()
		tween2.tween_property(node2, "color:a", 0.0, tween_timer) 
		tween2.tween_callback(func(): node2.queue_free()) 
	
	if node3: #tilemap node in gray_viewport
		var tween3 = create_tween()
		tween3.tween_property(node3, "modulate:a", 0.0, tween_timer)
		tween3.tween_callback(func(): node3.queue_free()) 
