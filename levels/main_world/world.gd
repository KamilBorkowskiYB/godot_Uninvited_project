extends Node2D

#@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _ready():
	var viewport1 = get_node("MainLevelViewport/SubViewport")
	var viewport2 = get_node("FogViewport")
	var viewport3 = get_node("VisibilityViewport")
	var viewport_dim_split = get_node("OtherDimension/DimensionsParser")
	var viewport_dim_split_occluders = get_node("OtherDimension/DimensionsParserOccluders")
	
	var od_viewport1 = get_node("OtherDimension/SubLevelViewport/ODSeenViewport")
	var od_viewport2 = get_node("OtherDimension/ODFogViewport")
	var od_viewport3 = get_node("OtherDimension/ODVisibilityViewport")
	var od_viewport_dim_split = get_node("OtherDimension/ODDimensionsParser")
	var od_viewport_dim_split_occluders = get_node("OtherDimension/ODDimensionsParserOccluders")
	
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	#setting viewports size to match project size
	var view_size = get_viewport().get_visible_rect().size
	viewport1.size = view_size
	viewport2.size = view_size
	viewport3.size = view_size
	viewport_dim_split.size = view_size
	viewport_dim_split_occluders.size = view_size
	od_viewport1.size = view_size
	od_viewport2.size = view_size
	od_viewport3.size = view_size
	od_viewport_dim_split.size = view_size
	od_viewport_dim_split_occluders.size = view_size
	
	#connecting viewport cameras
	viewport1 = get_node("MainLevelViewport/SubViewport/MainScene")
	var cam_main = viewport1.get_node_or_null("PlayerCamera")
	var cam_fog = viewport2.get_node_or_null("Camera2D")
	var cam_view = viewport3.get_node_or_null("Camera2D")
	var cam_dim_split = viewport_dim_split.get_node_or_null("Camera2D")
	var cam_dim_split_occluders = viewport_dim_split_occluders.get_node_or_null("Camera2D")
	var cam_od_main = od_viewport1.get_node_or_null("Camera2D")
	var cam_od_fog = od_viewport2.get_node_or_null("Camera2D")
	var cam_od_view = od_viewport3.get_node_or_null("Camera2D")
	var cam_od_dim_split = od_viewport_dim_split.get_node_or_null("Camera2D")
	var cam_od_dim_split_occluders = od_viewport_dim_split_occluders.get_node_or_null("Camera2D")
	
	if(cam_main and cam_fog and cam_view):
		cam_main.vision_camera = cam_view
		cam_main.fog_camera = cam_fog
	if(cam_main and cam_dim_split and cam_dim_split_occluders and cam_od_dim_split and cam_od_dim_split_occluders):
		cam_main.dim_split_camera = cam_dim_split
		cam_main.dim_split_camera_occluders = cam_dim_split_occluders
		cam_main.od_dim_split_camera = cam_od_dim_split
		cam_main.od_dim_split_camera_occluders = cam_od_dim_split_occluders
	if(cam_main and cam_od_main and cam_od_fog and cam_od_view):
		cam_main.od_main_camera = cam_od_main
		cam_main.od_fog_camera = cam_od_fog
		cam_main.od_vision_camera = cam_od_view
	
	#connecting VisionViewport lights to player
	var view_light = viewport3.get_node_or_null("ViewLight")
	var light_dim_split = viewport_dim_split.get_node_or_null("ViewDimensionLight")
	var light_dim_split_occluders = viewport_dim_split_occluders.get_node_or_null("ViewDimensionLight")
	var od_light_dim_split = od_viewport_dim_split.get_node_or_null("ViewDimensionLight")
	var od_light_dim_split_occluders = od_viewport_dim_split_occluders.get_node_or_null("ViewDimensionLight")
	var od_view_light = od_viewport3.get_node_or_null("ViewLight")
	if(player and view_light):
		player.view_light = view_light
		if(light_dim_split and od_view_light and light_dim_split_occluders and od_light_dim_split and od_light_dim_split_occluders):
			player.dim_split_light = light_dim_split
			player.dim_split_light_occluders = light_dim_split_occluders
			player.od_dim_split_light = od_light_dim_split
			player.od_dim_split_light_occluders = od_light_dim_split_occluders
			player.od_view_light = od_view_light
	
	##connecting tilemap to player footsteps
	connect_tilemap_to_footsteps(viewport1.get_child(0))
	
	#connecting aim assist to player 
	var aim = $WeaponSelected/AimAssist
	var aimL = $WeaponSelected/AimAssist/AimAssistL
	var aimR = $WeaponSelected/AimAssist/AimAssistR
	if(player and aim and aimL and aimR):
		player.aim_assist = aim
		player.aim_assistR = aimR
		player.aim_assistL = aimL
	
	#TODO check if the following connections work in other dim
	#connecting signals from player
	if not player.player_has_died.is_connected(player_dead):#conneting connected singnal returns error
		player.player_has_died.connect(player_dead)
		player.weapon_info_on.connect(weapon_info_visible)
	
	#connecting signals from pickUps
	viewport1 = get_node("MainLevelViewport/SubViewport/MainScene").get_child(0).get_node("PickUps")
	for child in viewport1.get_children():
		if child.has_signal("item_picked_up"):
			child.item_picked_up.connect(item_picked_up)
	
	#connecting signals from LevelExits
	viewport1 = get_node("MainLevelViewport/SubViewport/MainScene").get_child(0).get_node("LevelExits")
	for child in viewport1.get_children():
		if child.has_signal("change_level"):
			child.change_level.connect(change_level)
	
	#connecting signals from Secrets
	viewport1 = get_node("MainLevelViewport/SubViewport/MainScene").get_child(0).get_child(0).get_node("Secrets")
	for child in viewport1.get_children():
		if child.get_child(0).has_signal("reveal_area"):
			child.get_child(0).reveal_area.connect(reveal_area)
	
	#connecting signals from Dimension Splits
	viewport1 = get_node("MainLevelViewport/SubViewport/MainScene").get_child(0).get_child(0).get_child(0).get_node("Static/DimensionSplits")
	for child in viewport1.get_children():
		if child.has_signal("swap_dimensions"):
			child.swap_dimensions.connect(swap_dimensions)
	od_viewport1 = get_node("OtherDimension/SubLevelViewport/ODSeenViewport").get_child(0).get_child(0).get_child(0).get_node("Static/DimensionSplits")
	for child in od_viewport1.get_children():
		if child.has_signal("swap_dimensions"):
			child.swap_dimensions.connect(swap_dimensions)
	
	#setting materials in viewport3 to white
	change_material_to_white(viewport3.get_child(0))
	change_material_to_white(viewport_dim_split.get_child(0))
	change_material_to_white(viewport_dim_split_occluders.get_child(0))
	change_material_to_white(od_viewport3.get_child(0))
	change_material_to_white(od_viewport_dim_split.get_child(0))
	change_material_to_white(od_viewport_dim_split_occluders.get_child(0))
	
	# Connecting movable blocks and doors
	viewport1 = get_node("MainLevelViewport/SubViewport/MainScene")
	viewport2 = get_node("FogViewport")
	viewport3 = get_node("VisibilityViewport")
	od_viewport1 = get_node("OtherDimension/SubLevelViewport/ODSeenViewport")
	od_viewport2 = get_node("OtherDimension/ODFogViewport")
	od_viewport3 = get_node("OtherDimension/ODVisibilityViewport")
	connect_movable_objects_between_viewports(viewport1, viewport2, viewport3)
	connect_movable_objects_between_viewports(od_viewport1, od_viewport2, od_viewport3)
	connect_dim_occluders(viewport1, viewport_dim_split_occluders)
	connect_dim_occluders(od_viewport1, od_viewport_dim_split_occluders)
	connect_dim_occluder_doors(viewport1, od_viewport1)
	
	# Hidding front elements in Visibility Viewport
	var transparent = get_tree().get_nodes_in_group("Transparent")
	for node in transparent:
		if viewport3.is_ancestor_of(node) or od_viewport3.is_ancestor_of(node):
			node.hide()
		if viewport_dim_split.is_ancestor_of(node) or od_viewport_dim_split.is_ancestor_of(node):
			node.hide()
		if viewport_dim_split_occluders.is_ancestor_of(node) or od_viewport_dim_split_occluders.is_ancestor_of(node):
			node.hide()
		# Disabling transparency in FogViewport
		if viewport2.is_ancestor_of(node) or od_viewport2.is_ancestor_of(node):
			var mat: Material = node.material
			if mat and mat is ShaderMaterial:
				mat.set_shader_parameter("fog_dont_show", true)
	# reloads transparency calculation on level change
	var player_camera = viewport1.get_node_or_null("PlayerCamera")
	if player_camera == null: player_camera = od_viewport1.get_node("PlayerCamera")
	player_camera._ready()
	
	#set tilemap z order to -12 in fogvp to show objects on top of overlay
	set_tilemap_z_order(viewport2)
	set_tilemap_z_order(od_viewport2)


func _process(_delta):
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player != null:
		$WeaponSelected/Control/Label.text = str(player.current_weapon["current_magazine"]) +"/"+ str(player.current_weapon["current_ammo"])
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
	if node.name.contains("Sounds"): return
	node.use_parent_material = true
	for child in node.get_children():
		change_material_to_white(child)


func change_level(player_pos,level_high,level_mid,level_low): #TODO add other dimension to level load
	get_node("MainLevelViewport/SubViewport/MainScene").get_child(0).queue_free()
	get_node("FogViewport").get_child(0).queue_free()
	get_node("VisibilityViewport").get_child(0).queue_free()
	get_node("OtherDimension/DimensionsParser").get_child(0).queue_free()
	
	var viewport1 = get_node("MainLevelViewport/SubViewport/MainScene")
	var viewport2 = get_node("FogViewport")
	var viewport3 = get_node("VisibilityViewport")
	var viewport_dim_split = get_node_or_null("OtherDimension/DimensionsParser")
	var od_viewport1 = get_node_or_null("OtherDimension/SubLevelViewport/ODSeenViewport")
	var od_viewport2 = get_node_or_null("OtherDimension/ODFogViewport")
	var od_viewport3 = get_node_or_null("OtherDimension/ODVisibilityViewport")
	
	var instance_high = load(level_high).instantiate()
	var instance_mid = load(level_mid).instantiate()
	var instance_low = load(level_low).instantiate()
	var instance_dim_split = load(level_low).instantiate()
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://shaders/visibilityMapShader.gdshader")
	instance_low.material = shader_material
	instance_dim_split.material = shader_material
	
	viewport1.add_child(instance_high)
	viewport2.add_child(instance_mid)
	viewport3.add_child(instance_low)
	viewport_dim_split.add_child(instance_dim_split)
	
	viewport1.move_child(instance_high,0)
	viewport2.move_child(instance_mid,0)
	viewport3.move_child(instance_low,0)
	viewport_dim_split.move_child(instance_dim_split,0)
	
	set_tilemap_z_order(viewport2)
	set_tilemap_z_order(od_viewport2)
	
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	player.position = player_pos
	_ready()
	InteractionManager.active_areas = []
	InteractionManager.mouse_range = []


var what_dimenstion = 0.0 # 0 - main dim ; 1 - other dim
func swap_dimensions():
	var main_vp_container = get_node("MainLevelViewport")
	var od_vp_container = get_node_or_null("OtherDimension/SubLevelViewport")
	
	var viewport1 = get_node("MainLevelViewport/SubViewport/MainScene")
	var main_dim_seen = viewport1.get_child(0)
	#viewports2 are animeted in the above tween
	var viewport3 = get_node("VisibilityViewport")
	var od_viewport1 = get_node_or_null("OtherDimension/SubLevelViewport/ODSeenViewport")
	var other_dim_seen = od_viewport1.get_child(0)
	var od_viewport3 = get_node_or_null("OtherDimension/ODVisibilityViewport")
	
	var viewport_dim_split = get_node_or_null("OtherDimension/DimensionsParser")
	var viewport_dim_split_occluders = get_node_or_null("OtherDimension/DimensionsParserOccluders")
	var od_viewport_dim_split = get_node_or_null("OtherDimension/ODDimensionsParser")
	var od_viewport_dim_split_occluders = get_node_or_null("OtherDimension/ODDimensionsParserOccluders")
	
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	var player_camera = player.get_parent().get_node("PlayerCamera")
	var dummy = od_viewport1.get_node("DummyPlayer") if player.get_parent().name.contains("MainScene") else viewport1.get_node("DummyPlayer")
	var dummy_camera = dummy.get_parent().get_node("Camera2D")
	
	if what_dimenstion == 0.0:
		main_vp_container.z_index = -1
		od_vp_container.z_index = 0
		viewport1.remove_child(player)
		viewport1.remove_child(player_camera)
		od_viewport1.remove_child(dummy)
		od_viewport1.remove_child(dummy_camera)
		viewport1.add_child(dummy)
		viewport1.add_child(dummy_camera)
		od_viewport1.add_child(player)
		od_viewport1.add_child(player_camera)
	else:
		main_vp_container.z_index = 0
		od_vp_container.z_index = -1
		viewport1.remove_child(dummy)
		viewport1.remove_child(dummy_camera)
		od_viewport1.remove_child(player)
		od_viewport1.remove_child(player_camera)
		viewport1.add_child(player)
		viewport1.add_child(player_camera)
		od_viewport1.add_child(dummy)
		od_viewport1.add_child(dummy_camera)
	viewport1.move_child(main_dim_seen, 0)
	od_viewport1.move_child(other_dim_seen, 0)
	
	
	var shader_material = main_vp_container.material
	shader_material.set_shader_parameter("swap_fog_progress", what_dimenstion)
	var tween = create_tween()
	tween.tween_method(
		func(value):
			shader_material.set_shader_parameter("swap_fog_progress", value),
		what_dimenstion,
		abs(what_dimenstion-1.0),
		0.5
	)
	
	what_dimenstion = abs(what_dimenstion-1.0)
	
	var od_shader_material = od_vp_container.material
	od_shader_material.set_shader_parameter("swap_fog_progress", what_dimenstion)
	var od_tween = create_tween()
	od_tween.tween_method(
		func(value):
			od_shader_material.set_shader_parameter("swap_fog_progress", value),
		what_dimenstion,
		abs(what_dimenstion-1.0),
		0.5
	)
	
	if what_dimenstion == 1:
		connect_dim_occluders(od_viewport1, od_viewport_dim_split_occluders)
		connect_dim_occluder_doors(od_viewport1, viewport1)
		connect_tilemap_to_footsteps(other_dim_seen)
	else:
		connect_dim_occluders(viewport1, viewport_dim_split_occluders)
		connect_dim_occluder_doors(viewport1, od_viewport1)
		connect_tilemap_to_footsteps(main_dim_seen)


func reveal_area(secret_name: String):
	#TILESET MUST BE NAMED JUST LIKE SECRET 
	var viewport1 = get_node("MainLevelViewport/SubViewport/MainScene").get_child(0).get_child(0).get_node("Secrets")
	var viewport2 = get_node("FogViewport").get_child(0).get_node("out_of_view_overlay").get_node("SecretsColor") #lights secrets   #get_node("FogViewport").get_child(0).get_child(0).get_node("Secrets")
	var viewport2prim = get_node("FogViewport").get_child(0).get_node("out_of_view_overlay").get_node("SecretsModulate") #tileset and other overlay
	
	var node1 = viewport1.get_node(NodePath(secret_name))
	var node2 = viewport2.get_node(NodePath(secret_name))
	var node3 = viewport2prim.get_node_or_null(NodePath(secret_name))
	
	var tween_timer: float = 0.4
	var tween1 = create_tween()
	tween1.tween_property(node1, "color:a", 0.0, tween_timer) 
	tween1.tween_callback(func(): node1.queue_free())
	
	
	if node2:
		var tween2 = create_tween()
		for child in node2.find_children("*", "PointLight2D", true, false):
			tween2.parallel().tween_property(child, "color:a", 0.0, tween_timer)
		tween2.parallel().tween_property(node2, "color:a", 0.0, tween_timer)
		tween2.tween_callback(func(): node2.queue_free())
	
	
	if node3: #tilemap node in gray_viewport
		var tween3 = create_tween()
		tween3.tween_property(node3, "modulate:a", 0.0, tween_timer)
		tween3.tween_callback(func(): node3.queue_free()) 

func connect_movable_objects_between_viewports(viewport1, viewport2, viewport3): # Connecting movable blocks and doors within one dimension
	var all_movable = get_tree().get_nodes_in_group("movable_blocks")
	for node1 in all_movable:
		if not viewport1.is_ancestor_of(node1):
			continue
		
		var target_name = node1.name
		var node2 = null
		var node3 = null
		
		if node1.get_parent().name.contains("DoubleDoor") or node1.get_parent().name.contains("DimensionSplit"):
			for candidate in all_movable:
				if candidate.name == target_name and candidate.get_parent().name == node1.get_parent().name and viewport2.is_ancestor_of(candidate):
					node2 = candidate
			for candidate in all_movable:
				if candidate.name == target_name and candidate.get_parent().name == node1.get_parent().name and viewport3.is_ancestor_of(candidate):
					node3 = candidate
					break
		else:
			if node1.name.contains("GlassArea"):#windows
				for candidate in all_movable:
					if candidate.get_parent().name == node1.get_parent().name and viewport2.is_ancestor_of(candidate):
						node2 = candidate
						break
			else: #classic moving blocks - crates, normal doors, etc
				for candidate in all_movable:
					if candidate.name == target_name and viewport2.is_ancestor_of(candidate):
						node2 = candidate
						break
				for candidate in all_movable:
					if candidate.name == target_name and viewport3.is_ancestor_of(candidate):
						node3 = candidate
						break
		
		if node2:
			node1.linkedView = node2
		if node3:
			node1.linkedFog = node3
			
		#Connecting doors with hiden areas
		var ha1 = node1.get("hidden_area_name")
		if ha1 != null and ha1 != "": 
			node1.hidden_area = viewport1.get_child(0).get_child(0).get_node(node1.hidden_area_name)
		var ha2 = node1.get("hidden_area_name_two")
		if ha2 != null and ha2 != "": 
			node1.hidden_area_two = viewport1.get_child(0).get_child(0).get_node(node1.hidden_area_name_two)


func connect_dim_occluders(viewport_main, viewport_dim_split_occluders): #connects movable objects from main viewport to coresponding ones from DimensionParserOccluders
	var all_movable = get_tree().get_nodes_in_group("movable_blocks")
	for node1 in all_movable:
		if not viewport_main.is_ancestor_of(node1) or node1.name.contains("GlassArea"):
			continue
		
		var target_name = node1.name
		var node2 = null
		
		if node1.get_parent().name.contains("DimensionSplit"):
			for candidate in all_movable:
				if candidate.get_parent().name == node1.get_parent().name and candidate.name == target_name and viewport_dim_split_occluders.is_ancestor_of(candidate):
					node2 = candidate
					break
		else:
			for candidate in all_movable:
				if candidate.name == target_name and viewport_dim_split_occluders.is_ancestor_of(candidate):
					node2 = candidate
					break
		
		if node2:
			node1.linkedDimOcc = node2


func connect_dim_occluder_doors(main_viewport, other_main_viewport): #connects doors from main viewports to the corresponding ones from the other_dim_main
	var all_movable = get_tree().get_nodes_in_group("movable_blocks")
	for node1 in all_movable:
		if not main_viewport.is_ancestor_of(node1):
			continue
		
		var target_name = node1.name
		var node2 = null
		
		for candidate in all_movable:
			if candidate.name == target_name and candidate.get_parent().name == node1.get_parent().name and other_main_viewport.is_ancestor_of(candidate) and candidate.name.contains("Door"):
				node2 = candidate
				break
		
		if node2:
			node1.linkedOtherDim = node2
			node2.linkedOtherDim = null


func connect_tilemap_to_footsteps(viewport):
	#connecting tilemap to player footsteps
	var tilemap = null
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if viewport.get_child(0).get_child(0).get_node("Tilemap").get_child_count() > 0:
		tilemap = viewport.get_child(0).get_child(0).get_node("Tilemap").get_child(0)
	var footnode = player.get_node("Footsteps").get_child(0)
	if(footnode and tilemap):
		footnode.tilemap = tilemap
	
	#connecting tilemap to enemies footsteps
	viewport = get_node("MainLevelViewport/SubViewport/MainScene").get_child(0).get_node("Enemies")
	for child in viewport.get_children():
		if(child and tilemap):
			child.get_node_or_null("Footsteps").get_child(0).tilemap = tilemap
	
	#connecting tilemap to movingblocks
	viewport = get_node("MainLevelViewport/SubViewport/MainScene").get_child(0).get_child(0).get_child(0).get_node("MovingBlocks") #First get_child - lvl_hight, second - lvl_middium, third - lvl_low
	for child in viewport.get_children():
		if(child and tilemap):
			child.get_node_or_null("Footsteps").get_child(0).tilemap = tilemap


func set_tilemap_z_order(viewport):
	var tilemap_in_lvl_low = viewport.get_child(0).get_child(0).get_child(0).get_node_or_null("Tilemap").get_child(0)
	tilemap_in_lvl_low.z_index = -12 #if overlay doesn't cover make sure overlay is on is max on -1 layer than the one covered
