extends Node2D

@export var linkedView: Node2D
@export var linkedFog: Node2D 
@export var grabable: bool
var health = 150
var standing_on = "grass"
var move_direction = Vector2(0,0)

func _process(_delta):
	if linkedView != null:
		linkedView.transform = self.transform
	if linkedFog != null:
		linkedFog.transform = self.transform
	if standing_on == "water":
		self.mass = 10
		$WaterSplash.emitting = true
	else:
		self.mass = 1
		$WaterSplash.emitting = false

func kill(attack: Attack):
	$".".apply_central_impulse(-attack.attack_direction * 500)
	health -= attack.attack_damage
	if health <= 0:
		linkedView.queue_free()
		linkedFog.queue_free()
		queue_free()
