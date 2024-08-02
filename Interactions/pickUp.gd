extends CPUParticles2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
var item_name = "None"# displayed name 
var item_id = "None" # has to be equal to player unlock
enum items {#same as player pick ups
	Rifle_Ammo,
	Shotgun_Shells,
	Rifle_Unlock,
	Shotgun_Unlock,
}
@export var item_selected: items = items.Rifle_Ammo
signal item_picked_up(item_name)

func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
	match item_selected:
		items.Rifle_Ammo:
			item_id = "rifle_ammo"
			item_name = "Rifle ammo"
		items.Shotgun_Shells:
			item_id = "shotgun_shells"
			item_name = "Shotgun shells"
		items.Rifle_Unlock:
			item_id = "rifle_unlock"
			item_name = "Rifle"
		items.Shotgun_Unlock:
			item_id = "shotgun_unlock"
			item_name = "Shotgun"

func _on_interact():
	player.set(item_id, player.get(item_id) + 1)
	item_picked_up.emit(item_name)
	queue_free()

