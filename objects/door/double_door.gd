extends Node2D


@onready var Rdoor = $RightDoor
@onready var Ldoor = $LeftDoor
@onready var Rdoor_physics = $RightDoor/Door
@onready var Ldoor_physics = $LeftDoor/Door
@export var hidden_area_name: String

func _ready():
	Rdoor.hidden_area_name = hidden_area_name
	#Ldoor.hidden_area_name = hidden_area_name


func open_doors():
	Rdoor_physics.open()
	Ldoor_physics.open()


func close_doors():
	Rdoor_physics.close()
	Ldoor_physics.close()


func doors_shot(shot_door, attack_dir):
	if shot_door == Rdoor_physics and Ldoor_physics.isClosed:
		Ldoor_physics.isClosed = false
		Ldoor_physics.freeze = false
		Ldoor_physics.trigger_linked_event()
		Ldoor_physics.apply_central_impulse(-attack_dir * 250)
	if shot_door == Ldoor_physics and Rdoor_physics.isClosed:
		Rdoor_physics.isClosed = false
		Rdoor_physics.freeze = false
		Rdoor_physics.trigger_linked_event()
		Rdoor_physics.apply_central_impulse(-attack_dir * 250)
