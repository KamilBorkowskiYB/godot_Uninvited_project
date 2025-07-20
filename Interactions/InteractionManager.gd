extends Node2D

@onready var label = $Label

@onready var cursor_interact = load("res://cursor/cursor_interact.png")
@onready var cursor_aim = load("res://cursor/cursor_aim.png")
@onready var cursor_normal = load("res://cursor/cursor_normal.png")

const base_text = "[LMB] to "

var active_areas = []#in player range
var mouse_range = []#in mouse range
var intersecting_areas = []
var can_interact = true

func register_in_mouse_range(area: InteractionArea):
	mouse_range.push_back(area)

func unregister_in_mouse_range(area: InteractionArea):
	var index = mouse_range.find(area)
	if index != -1:
		mouse_range.remove_at(index)

func register_area(area: InteractionArea):
	active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(_delta):
	var player_help = get_tree().get_first_node_in_group("player")
	
	intersecting_areas = []
	
	var grabbed_area = null
	if player_help != null and player_help.grabbed_object != null:
		grabbed_area = player_help.grabbed_object.interaction_area
		
	for area in active_areas:
		if mouse_range.has(area):
			intersecting_areas.append(area)
		elif area == grabbed_area and grabbed_area != null:
			intersecting_areas.append(grabbed_area)
	
	if intersecting_areas.size() > 0 and can_interact:
		intersecting_areas.sort_custom(_sort_by_distance_to_player)
		
		if player_help != null and player_help.grabbed_object != null:# if grabbing an object, then only it can be interacted with
			intersecting_areas.erase(grabbed_area)
			intersecting_areas.insert(0, grabbed_area)
		
		var area = intersecting_areas[0]
		label.text = base_text + area.action_name
		
		var mouse_pos = get_viewport().get_mouse_position()
		label.global_position = mouse_pos + Vector2(-75, 30)
		
		if player_help.cursor_current != cursor_aim:
			label.show()
			Input.set_custom_mouse_cursor(cursor_interact, Input.CURSOR_ARROW, Vector2(24, 24))
		else:
			label.hide()
	else:
		label.hide()
	if player_help != null and player_help.cursor_current != cursor_aim:
		Input.set_custom_mouse_cursor(cursor_normal, Input.CURSOR_ARROW, Vector2(24, 24))


func _sort_by_distance_to_player(area1, area2):
	var player_help = get_tree().get_first_node_in_group("player")
	var area1_to_player = player_help.global_position.distance_to(area1.global_position)
	var area2_to_player = player_help.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player
	

func _input(event):
	var player_help = get_tree().get_first_node_in_group("player") #after restart player is freed 
	
	var grabbed_area = null
	if player_help != null and player_help.grabbed_object != null:
		grabbed_area = player_help.grabbed_object.interaction_area
	
	if event.is_action_pressed("shoot") and can_interact and player_help.cursor_current != cursor_aim and intersecting_areas.size() > 0:
		var area_to_interact = intersecting_areas[0]
		can_interact = false
		label.hide()
		await area_to_interact.interact.call()
		can_interact = true
