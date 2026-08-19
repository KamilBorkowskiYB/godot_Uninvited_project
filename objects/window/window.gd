extends Area2D

@export var health = 15
@export var linkedView: Node2D
@onready var glass_sprite = $"../GlassSprite"
@onready var destory_sound = $"../Sounds/GlassDestroy"
@onready var hit_heavy = $"../Sounds/GlassHitHeavy"
@onready var hit_soft = $"../Sounds/GlassHitSoft"

func take_damage(attack_info: Attack):
	print("Window attacked")
	health -= attack_info.attack_damage
	play_sound(hit_soft.stream)
	if health <= 0:
		kill()

func kill():
	glass_sprite.hide()
	if linkedView: 
		linkedView.kill()
		play_sound(destory_sound.stream)
	queue_free()


func play_sound(stream: AudioStream):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	get_parent().add_child(player)
	player.pitch_scale = randf_range(0.8, 1.2)
	player.play()
	
	player.finished.connect(player.queue_free)
