extends Area2D

@export var damage = 50;
signal body_attacked(body)

func _on_body_entered(body):
	if (body.has_method("take_damage") or body.has_method("kill")) and !body.name.contains("guest_enemy"):
		body_attacked.emit(body)

	#var attack = Attack.new()
	#attack.attack_damage = damage
	#attack.attack_direction = direction
	#if body.has_method("take_damage"):
		#body.take_damage(attack_info)
	#elif body.has_method("kill"):
		#body.kill()
