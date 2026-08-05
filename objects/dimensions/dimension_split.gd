extends Node2D

signal swap_dimensions

var swap_distance := 17.0
var occluder_offset := 15.0
var entered_from_top_or_left = false
var border_width = 135.0
var occluder_speed := 240.0
var min_distance := 5.0
@onready var lightOccluder = $LightOccluder2D
var lightOccRestPos
@onready var area = $Area2D
@export var has_door: bool = true
@export var horizontal: bool = true


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		if horizontal:
			entered_from_top_or_left = body.global_position.y < area.global_position.y
		else:
			entered_from_top_or_left = body.global_position.x < area.global_position.x


func _ready():
	var door = get_node_or_null("DimensionDoor/Door")
	if horizontal : lightOccRestPos = position.y
	else : lightOccRestPos = position.x
	border_width = 171 * scale.x # 171 is a width of light occ (x of point 1)
	
	await get_tree().physics_frame
	if !has_door and door:
		door.calc_health(900)

var target
var player_pos
var player_width_pos
var light_occ_pos
var light_occ_width_pos
func _process(delta):
	var overlapping_bodies = area.get_overlapping_bodies()
	
	target = lightOccRestPos
	set_horizontal_vars()
	
	if abs(player_pos - lightOccRestPos) <= swap_distance:
		if abs(player_width_pos - light_occ_width_pos) < border_width:
			if player_pos < lightOccRestPos:
				target = lightOccRestPos + occluder_offset
				target = max(target, player_pos + min_distance)
			else:
				target = lightOccRestPos - occluder_offset
				target = min(target, player_pos - min_distance)
	else:
		target = lightOccRestPos
	
	if horizontal: lightOccluder.global_position.y = target #TODO zamiast przesuwać wizualną granicę poprzez move() lepiej będzie dodać "próg" w aktualnym dimension, który wygląda jak other dimension i jest widziany jedynie przed granicą
	else: lightOccluder.global_position.x = target          #wsm to nie - nie zadziała jeśli gracz jest przed granicą ale na nią nie patrzy - trzeba zadbać aby wszystkie progi były takie same między dimensions
	
	#swaping dimensions
	for body in overlapping_bodies:
		if body.is_in_group("player"):
			var center = area.global_position.y if horizontal else area.global_position.x
			var player_pos = body.global_position.y if horizontal else body.global_position.x
			#enter from top
			if entered_from_top_or_left:
				if player_pos > center:
					call_deferred("emit_swap")
			#enter from bottom
			else:
				if player_pos < center:
					call_deferred("emit_swap")


func emit_swap():
	swap_dimensions.emit()


func set_horizontal_vars():
	var player = get_tree().get_first_node_in_group("player")
	if horizontal:
		player_pos = player.global_position.y
		player_width_pos = player.global_position.x
		light_occ_pos = lightOccluder.global_position.y
		light_occ_width_pos = lightOccluder.global_position.x
	else:
		player_pos = player.global_position.x
		player_width_pos = player.global_position.y
		light_occ_pos = lightOccluder.global_position.x
		light_occ_width_pos = lightOccluder.global_position.y
