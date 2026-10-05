extends Node2D

@export var active: bool = true
var max_capacity = 1
var current_alive = 0


func _process(_delta):
	if current_alive < max_capacity and active:
		create_guest()
		current_alive = current_alive + 1


func create_guest():
	var enemy_scene = load(
		"res://characters/guest/guest_enemy.tscn"
	)
	var new_enemy = enemy_scene.instantiate()
	new_enemy.name = "GuestEnemy"
	new_enemy.died.connect(spawn_died)
	
	var enemies_node = get_parent().get_parent().get_node_or_null("Enemies")
	new_enemy.global_transform = self.global_transform
	enemies_node.add_child(new_enemy)
	new_enemy.connect_tilemap()
	new_enemy.show()
	
	#match enemy_state:
		#EnemiesStates.IDLE:
			#pass
		#
		#EnemiesStates.CHASE:
			#call_deferred("start_enemy_chase")


func spawn_died():
	current_alive =  current_alive - 1


func toggle_active():
	active = !active
