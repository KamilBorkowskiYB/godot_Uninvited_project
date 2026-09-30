extends Area2D

signal got_shot
var damage_multiplier = 30 #just add bonus seems better

func kill(attack: Attack):
	$Sprite2D.hide()
	$CollisionShape2D.queue_free()
	$CPUParticles2D.finished.connect(queue_free, CONNECT_ONE_SHOT)
	$CPUParticles2D.emitting = true
	attack.attack_damage = attack.attack_damage + damage_multiplier
	play_sound($DamageTaken)
	play_sound($DamageTaken2)
	got_shot.emit(attack)

func take_damage(attack: Attack):
	kill(attack)


func play_sound(audio_player: AudioStreamPlayer2D):
	var sound := AudioStreamPlayer2D.new()
	sound.stream = audio_player.stream
	sound.volume_db = audio_player.volume_db
	sound.pitch_scale = audio_player.pitch_scale
	sound.bus = audio_player.bus
	sound.max_distance = audio_player.max_distance
	sound.attenuation = audio_player.attenuation
	sound.panning_strength = audio_player.panning_strength
	sound.global_position = global_position
	var ancestor := get_parent()
	while ancestor and not ancestor is CharacterBody2D:
		ancestor = ancestor.get_parent()
	if ancestor:
		ancestor.add_child(sound)
	else:
		push_warning("Could not find CharacterBody2D ancestor for sound")
	sound.finished.connect(sound.queue_free)
	sound.play()
