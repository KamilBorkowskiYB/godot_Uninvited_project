extends CharacterBody2D

##########        PLAYER NODES        ##########
@onready var top = $Top
@onready var player_top_sprite = $Top/Alive_New
@onready var bottom = $Bottom
@onready var legs = $Bottom/Legs
@onready var ray_cast1 = top.get_node("RayCasts/RayCast2D")
@onready var ray_cast2 = top.get_node("RayCasts/RayCast2D2")
@onready var ray_cast3 = top.get_node("RayCasts/RayCast2D3")
@onready var ray_cast4 = top.get_node("RayCasts/RayCast2D4")
@onready var animation_player = $AnimationPlayerTOP
@onready var animation_playerLegs = $AnimationPlayerLEGS
@onready var animation_run_rotation = $AnimationPlayerRUNROT
@onready var bullet_trail = load("res://characters/player/misc/shot_trail.tscn")


func _process(_delta):
	pass


func _physics_process(_delta):
	pass


func shoot(): #should shoot at the same time as player - create the same trail and deal damage (with the same values as the player)
	pass

