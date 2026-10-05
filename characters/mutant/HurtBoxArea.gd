extends Area2D

signal got_hit_head(attack: Attack)
var hit_sound = load("res://characters/guest/Blood_squirt.mp3")

#func kill(attack: Attack):#func not used
	#pass

func take_damage(attack: Attack):
	var sound = AudioStreamPlayer2D.new()
	sound.stream = hit_sound
	
	var ancestor := get_parent()
	while ancestor and not ancestor is CharacterBody2D:
		ancestor = ancestor.get_parent()
	if ancestor:
		ancestor.add_child(sound)
	
	sound.global_position = global_position
	sound.play()
	got_hit_head.emit(attack)
