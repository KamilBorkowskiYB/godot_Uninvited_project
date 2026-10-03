@tool
extends Area2D
signal reveal_area

enum TriggerAction {
	REVEAL_PARENT,
	PASS_ON,
	SPAWN_ENEMIES,
	TOGGLE_SPAWNER
}

enum Enemies {
	GUEST,
	PACIENT
}

enum EnemiesStates {
	IDLE,
	CHASE
}


@export var action: TriggerAction = TriggerAction.REVEAL_PARENT:
	set(value):
		action = value
		
		if Engine.is_editor_hint():
			call_deferred("update_editor_enemy")


@export var enemy: Enemies = Enemies.GUEST
@export var enemy_state: EnemiesStates = EnemiesStates.IDLE
@export var enemy_instance: CharacterBody2D
var enemy_global_transform: Transform2D
@export var trigger_node: Node2D

func _ready():
	if Engine.is_editor_hint():
		call_deferred("update_editor_enemy")
		return
	
	if action == TriggerAction.SPAWN_ENEMIES:
		if is_instance_valid(enemy_instance):
			enemy_global_transform = enemy_instance.global_transform
			remove_child(enemy_instance)


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
			call_deferred("spawn_enemies")
		
		TriggerAction.TOGGLE_SPAWNER:
			toggle_spawner()
	
	queue_free()


func reveal_parent():
	var parent_name = get_parent().name
	reveal_area.emit(
		parent_name,
		get_parent().related_ambient_darkness
	)


func pass_on_trigger():
	pass


func play_cutscene():
	pass


func toggle_spawner():
	if trigger_node.has_method("toggle_active"):
		trigger_node.toggle_active()


func spawn_enemies():
	if not is_instance_valid(enemy_instance):
		return
	
	var enemies_node = get_parent().get_parent().get_node_or_null("Enemies")
	if enemies_node == null:
		push_error(
			"TriggerEvent: nie znaleziono node'a 'Enemies'."
		)
		return
	
	enemies_node.add_child(enemy_instance)
	enemy_instance.global_transform = enemy_global_transform
	enemy_instance.connect_tilemap()
	enemy_instance.show()
	enemy_instance.process_mode = Node.PROCESS_MODE_INHERIT
	
	match enemy_state:
		EnemiesStates.IDLE:
			pass
		
		EnemiesStates.CHASE:
			call_deferred("start_enemy_chase")


func start_enemy_chase():
	if not is_instance_valid(enemy_instance):
		return
	
	enemy_instance.player_spoted()
	print("Enemy gave chase")


# ============================================================
# EDITOR
# ============================================================

func update_editor_enemy():
	if not Engine.is_editor_hint():
		return
	if action != TriggerAction.SPAWN_ENEMIES:
		_remove_editor_enemy()
		return
	if is_instance_valid(enemy_instance):
		return
	
	create_editor_enemy()


func create_editor_enemy():
	if not Engine.is_editor_hint():
		return
	
	match enemy:
		Enemies.GUEST:
			create_guest()
		Enemies.PACIENT:
			create_guest() # change in the future


func create_guest():
	var enemy_scene = load(
		"res://characters/guest/guest_enemy.tscn"
	)
	if enemy_scene == null:
		push_error(
			"TriggerEvent: nie można załadować guest_enemy.tscn"
		)
		return
	var new_enemy = enemy_scene.instantiate()
	
	new_enemy.name = "GuestEnemy"
	add_child(new_enemy)
	new_enemy.owner = get_tree().edited_scene_root
	enemy_instance = new_enemy
	
	new_enemy.position = Vector2.ZERO
	new_enemy.rotation = 0.0
	notify_property_list_changed()


func _remove_editor_enemy():
	if not Engine.is_editor_hint():
		return
	
	if not is_instance_valid(enemy_instance):
		enemy_instance = null
		return
	if enemy_instance.get_parent() == self:
		enemy_instance.queue_free()
	
	enemy_instance = null
	
	notify_property_list_changed()
