extends Area2D

signal got_hit_head(attack: Attack)

func kill(attack: Attack):
	got_hit_head.emit(attack)

func take_damage(attack: Attack):
	got_hit_head.emit(attack)
