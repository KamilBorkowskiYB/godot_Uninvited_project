extends Node2D

@export var linkedView: Node2D
@export var linkedFog: Node2D 


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
