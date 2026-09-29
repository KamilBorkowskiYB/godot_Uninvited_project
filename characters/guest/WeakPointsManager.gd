@tool
extends Node


@export var randomize_weak_points: bool = false:
	set(value):
		randomize_weak_points = false
		
		if value:
			randomize_points()

@export var hide_all: bool = false:
	set(value):
		hide_all = false
		if value:
			hide_all_weak_points()


func randomize_points():
	var weak_points: Array[Node] = []
	var weak_points_count = randi_range(3, 5)
	find_weak_points(get_parent(), weak_points)
	
	weak_points.shuffle()
	for i in range(weak_points_count, weak_points.size()):
		weak_points[i].hide()
		
	for i in range(0, weak_points_count):
		var s = randf_range(0.7, 1.3)
		weak_points[i].scale = Vector2(s, s)
		weak_points[i].show()


func hide_all_weak_points():
	var weak_points: Array[Node] = []
	find_weak_points(get_parent(), weak_points)
	for i in range(0, weak_points.size()):
		weak_points[i].hide()

func find_weak_points(node: Node, result: Array[Node]):
	for child in node.get_children():
		if child.is_in_group("weak_point"):
			result.append(child)
		find_weak_points(child, result)
