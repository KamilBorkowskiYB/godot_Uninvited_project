extends Area2D

signal got_shot
var damage_multiplier = 3

func kill(attack: Attack):
	$Sprite2D.hide()
	$CollisionShape2D.queue_free()
	$CPUParticles2D.finished.connect(queue_free, CONNECT_ONE_SHOT)
	$CPUParticles2D.emitting = true
	attack.attack_damage = attack.attack_damage * damage_multiplier
	got_shot.emit(attack)
