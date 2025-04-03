extends Area2D

@export var damage = 50;

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.kill()
