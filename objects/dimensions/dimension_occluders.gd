extends Node2D
#code for bodies that can obscure other dimension vis based on their position
# vis_from_right_or_bottom should be changed manually via triggers - imposible to dynamically decide if wall is left or right of viewing border if there are multiple borders
# shit fix proposition - don't let to see two borders at the same time, see only the closest border
@export var vertical:bool = true
@export var vis_from_right_or_bottom:bool = true
@export var always_visible:bool = false
@onready var light_occ = $LightOccluder2D
var distance_threshold = 5
var occ_mask_1and9 = 257
var occ_mask_1 = 1

func _process(_delta):#some code could be moved into onready func if changing levels won't mess up player and dimension_border values
	if always_visible: return
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	var other_dim_viewport = get_tree().root.get_node_or_null("World/OtherDimension/ODVisibilityViewport") 
	#var dimension_border = get_tree().get_first_node_in_group("dimension_split") #not used
	
	var closest_distance = INF
	var closest_dimension_border = null
	#var closest_distance_to_player = INF
	#var closest_dimension_border_to_player = null
	for node in get_tree().get_nodes_in_group("dimension_split"):
		var dist = global_position.distance_to(node.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest_dimension_border = node
		#var dist_to_payer = player.global_position.distance_to(node.global_position)
		#if dist_to_payer < closest_distance_to_player:
			#closest_distance_to_player = dist_to_payer
			#closest_dimension_border_to_player = node
	
	if other_dim_viewport and other_dim_viewport.is_ancestor_of(self):
		#warunek if poniższe ma sie wykonać jesli gracz i self są po tej samej stronie na osi y wzgledem closest_dimension_border
		var player_side = player.position.y - closest_dimension_border.position.y
		var self_side = position.y - closest_dimension_border.position.y # jesli border jest horyzontaly, przeciwnie powinno byc po x
		
		if player_side * self_side > 0:
			light_occ.occluder_light_mask = 0
			return
	
	if vertical:
		#var side_x = position.x - closest_dimension_border_to_player.position.x
		#if side_x > 0 : vis_from_right_or_bottom = true
		#else : vis_from_right_or_bottom = false
		set_occ_mask(player.position.x - self.position.x)
	else:
		#var side_y = position.y - closest_dimension_border_to_player.position.y
		#if side_y > 0 : vis_from_right_or_bottom = true
		#else : vis_from_right_or_bottom = false
		set_occ_mask(player.position.y - self.position.y)

func set_occ_mask(player_distance):
	if vis_from_right_or_bottom:
		if player_distance < distance_threshold:
			light_occ.occluder_light_mask = occ_mask_1
		else:
			light_occ.occluder_light_mask = occ_mask_1and9
	else:
		if player_distance > distance_threshold:
			light_occ.occluder_light_mask = occ_mask_1
		else:
			light_occ.occluder_light_mask = occ_mask_1and9
