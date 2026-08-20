extends Area2D

@export var health = 15
@export var linkedView: Node2D
@onready var glass_sprite = $"../GlassSprite"
@onready var destory_sound = $"../Sounds/GlassDestroy"
@onready var hit_heavy = $"../Sounds/GlassHitHeavy"
@onready var hit_soft = $"../Sounds/GlassHitSoft"
@onready var shattered_glass = $"../ShatteredGlass"
@onready var shattered_glass_area = $"../ShatteredGlassFloorArea/Area2D"


func take_damage(attack_info: Attack):
	glass_sprite.frame = 1
	health -= attack_info.attack_damage
	play_sound(hit_soft.stream)
	if health <= 0:
		kill()


func kill():
	glass_sprite.frame = 2
	set_shattered_glass()
	shattered_glass.show()
	shattered_glass_area.collision_layer = 64 #col layer 7 - footsteps
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


func set_shattered_glass():
	if linkedView:
		for glass_piece in shattered_glass.get_children():
			var glass_rotation = randf_range(0.0, 90.0)
			glass_piece.rotation = glass_rotation
			linkedView.shattered_glass.get_node(NodePath(glass_piece.name)).rotation = glass_rotation
			var glass_scale = randf_range(0.8, 1.25)
			glass_piece.scale.x = glass_scale
			glass_piece.scale.y = glass_scale
			linkedView.shattered_glass.get_node(NodePath(glass_piece.name)).scale.x = glass_scale
			linkedView.shattered_glass.get_node(NodePath(glass_piece.name)).scale.y = glass_scale
