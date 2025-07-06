extends Node2D

@export var linkedView: Node2D
@export var linkedFog: Node2D
@export var high: bool
@export var grabable: bool

var health = 150
var standing_on = "grass"
var move_direction = Vector2(0,0)

func _ready():
	if high:
		$".".set_collision_layer_value(2, true)
		$".".set_collision_layer_value(3, false)
	else:
		$".".set_collision_layer_value(2, false)
		$".".set_collision_layer_value(3, true)
		$BlockSprite/LightOccluder2D.hide()

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
