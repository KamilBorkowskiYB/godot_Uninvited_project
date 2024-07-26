extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label = $Label

@onready var cursor_interact = load("res://cursor/cursor_interact.png")
@onready var cursor_aim = load("res://cursor/cursor_aim.png")
@onready var cursor_normal = load("res://cursor/cursor_normal.png")

const base_text = "[LMB] to "

var active_areas = []#in player range
var mouse_range = []#in mouse range
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
	var player_help = get_tree().get_first_node_in_group("player") #after restart player is freed 
	if active_areas.size() > 0 && can_interact && mouse_range.size() > 0 && mouse_range.find(active_areas[0]) != -1:
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		var mouse_pos = get_viewport().get_mouse_position()
		label.global_position.y = mouse_pos.y + 30
		label.global_position.x = mouse_pos.x - 75
		if player_help.cursor_current != cursor_aim:
			label.show()
			Input.set_custom_mouse_cursor(cursor_interact,Input.CURSOR_ARROW,Vector2(24,24))
		else:
			label.hide()
	else:
		label.hide()
		if player_help != null and player_help.cursor_current != cursor_aim:
			Input.set_custom_mouse_cursor(cursor_normal,Input.CURSOR_ARROW,Vector2(24,24))


func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player
	
func _input(event):
	var player_help = get_tree().get_first_node_in_group("player") #after restart player is freed 
	if event.is_action_pressed("shoot") && can_interact && player_help.cursor_current != cursor_aim:
		if active_areas.size() > 0:
			if mouse_range.find(active_areas[0]) != -1:
				can_interact = false
				label.hide()
				await  active_areas[0].interact.call()
				can_interact = true
