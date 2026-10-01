extends Area2D

signal got_hit_head(attack: Attack)
var hit_sound = load("res://characters/guest/Blood_squirt.mp3")

func kill(attack: Attack):#func not used
	var sound = AudioStreamPlayer2D.new()
	sound.stream = hit_sound
	sound.global_position = global_position
	get_tree().current_scene.add_child(sound)#FIX, wrong place
	sound.play()
	got_hit_head.emit(attack)

func take_damage(attack: Attack):
	var sound = AudioStreamPlayer2D.new()
	sound.stream = hit_sound
	sound.global_position = global_position
	get_tree().current_scene.add_child(sound)#FIX, wrong place
	sound.play()
	got_hit_head.emit(attack)
