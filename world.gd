extends Node2D


func _ready():
	var viewport1 = get_node("MainLevelViewport/SubViewport/Level/Enviroment")
	var viewport2 = get_node("FadeoutViewport/SubViewport/Enviroment")
	var viewport3 = get_node("VisionConeViewport/VisibilityViewport/Enviroment")
	
	for i in range(4):#connecting doors
		if(i==0):
			var node1 = viewport1.get_node_or_null("Door")
			var node2 = viewport2.get_node_or_null("Door")
			var node3 = viewport3.get_node_or_null("Door")
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
		else:
			var node1 = viewport1.get_node_or_null("Door" + str(i))
			var node2 = viewport2.get_node_or_null("Door" + str(i))
			var node3 = viewport3.get_node_or_null("Door" + str(i))
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
	
	for i in range(4):#connecting Moving block
		if(i==0):
			var node1 = viewport1.get_node_or_null("MovingBlock")
			var node2 = viewport2.get_node_or_null("MovingBlock")
			var node3 = viewport3.get_node_or_null("MovingBlock")
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
		else:
			var node1 = viewport1.get_node_or_null("MovingBlock" + str(i))
			var node2 = viewport2.get_node_or_null("MovingBlock" + str(i))
			var node3 = viewport3.get_node_or_null("MovingBlock" + str(i))
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
	
	for i in range(4):#connecting lowMoving block
		if(i==0):
			var node1 = viewport1.get_node_or_null("lowMovingBlock")
			var node2 = viewport2.get_node_or_null("lowMovingBlock")
			var node3 = viewport3.get_node_or_null("lowMovingBlock")
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
		else:
			var node1 = viewport1.get_node_or_null("lowMovingBlock" + str(i))
			var node2 = viewport2.get_node_or_null("lowMovingBlock" + str(i))
			var node3 = viewport3.get_node_or_null("lowMovingBlock" + str(i))
			if(node1 and node2 and node3):
				node1.linkedView = node2
				node1.linkedFog = node3
