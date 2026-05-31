extends Area2D


func _ready():
	pass


func _process(delta):
	pass


func kill(attack: Attack):
	print("Weak point hit!")
	$Sprite2D.hide()
	$CollisionShape2D.queue_free()
	$CPUParticles2D.finished.connect(queue_free, CONNECT_ONE_SHOT)
	$CPUParticles2D.emitting = true
