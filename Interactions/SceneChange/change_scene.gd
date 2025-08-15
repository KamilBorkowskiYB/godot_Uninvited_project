extends Node2D

@onready var interaction_area: InteractionArea = $interaction_area
@onready var mouse_interaction_area = $MouseRangeInteraction

@export var level_high:String
@export var level_mid:String
@export var level_low:String
@export var player_position: Vector2
@export var level_name:String = "None"

signal change_level

func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
	mouse_interaction_area.parent_interaction = interaction_area
	interaction_area.action_name = "Enter " + level_name

func _on_interact():
	change_level.emit(player_position,level_high,level_mid,level_low)
