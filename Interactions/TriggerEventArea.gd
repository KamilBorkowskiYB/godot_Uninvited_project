extends Area2D

signal reveal_area
enum TriggerAction { REVEAL_PARENT, PASS_ON, SPAWN_ENEMIES }
enum Enemies { GUEST, PACIENT }
enum EnemiesStates { IDLE, CHASE }

@export var action: TriggerAction = TriggerAction.REVEAL_PARENT
@export var enemy: Enemies = Enemies.GUEST
@export var enemy_state: EnemiesStates = EnemiesStates.IDLE
@export var enemy_position: Vector2
@export var enemy_rotation: float

@onready var guest = load("res://characters/guest/guest_enemy.tscn")

func _on_body_entered(body):
	if body.is_in_group("player"):
		trigger_event()


func trigger_event():
	match action:
		TriggerAction.REVEAL_PARENT:
			reveal_parent()
		TriggerAction.PASS_ON:
			pass_on_trigger()
		TriggerAction.SPAWN_ENEMIES:
			call_deferred("spawn_enemies",enemy, enemy_state, enemy_position, enemy_rotation)
	queue_free()


func reveal_parent():
	var parent_name = get_parent().name
	reveal_area.emit(parent_name, get_parent().related_ambient_darkness)


func pass_on_trigger():
	pass


func play_cutscene():
	pass


func spawn_enemies(enemy_type, start_state, enemy_pos, enemy_rot):
	var enemy_scene
	var state
	match enemy_type:
		Enemies.GUEST:
			enemy_scene = guest
		Enemies.PACIENT:
			enemy_scene = guest # change in the future
	match start_state:
		EnemiesStates.IDLE:
			state = 1
		EnemiesStates.CHASE:
			state = 0
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.position = enemy_pos
	enemy_instance.rotation = enemy_rot
	
	get_parent().get_parent().get_node("Enemies").add_child(enemy_instance)
	if state == 0: enemy_instance.player_spoted()
