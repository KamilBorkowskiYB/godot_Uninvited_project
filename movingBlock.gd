extends Node2D

@export var linkedView: Node2D
@export var linkedFog: Node2D 

func _process(_delta):
	if linkedView != null:
		linkedView.transform = self.transform
	if linkedFog != null:
		linkedFog.transform = self.transform
