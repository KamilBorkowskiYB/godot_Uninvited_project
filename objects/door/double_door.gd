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
