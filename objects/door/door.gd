extends Node2D

var linkedView: Node2D
var linkedFog: Node2D
@export var hidden_area_name: String
var hidden_area: Node2D

func _ready():
	$Door.destroyed.connect(destroyed)

func _process(_delta):
	if linkedView != null:
		linkedView.get_node("Door").transform = $Door.transform
	if linkedFog != null:
		linkedFog.get_node("Door").transform = $Door.transform

func destroyed():
	if linkedView != null:
		linkedView.queue_free()
	if linkedFog != null:
		linkedFog.queue_free()
