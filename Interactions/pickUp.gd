extends CPUParticles2D

@onready var interaction_area: InteractionArea = $InteractionArea
var item_name = "None"# displayed name 
var item_id = "None" # has to be equal to player unlock
var is_space
enum items {#same as player pick ups
	Rifle_Ammo,
	Shotgun_Shells,
	Pistol_Ammo,
	Rifle_Unlock,
	Shotgun_Unlock,
	Pistol_Unlock,
}
@export var item_selected: items = items.Rifle_Ammo
signal item_picked_up(is_space,item_name)

func _ready():
	interaction_area.interact = Callable(self,"_on_interact")
	match item_selected:
		items.Rifle_Ammo:
			item_id = "rifle_ammo"
			item_name = "Rifle ammo"
		items.Shotgun_Shells:
			item_id = "shotgun_shells"
			item_name = "Shotgun shells"
		items.Pistol_Ammo:
			item_id = "pistol_ammo"
			item_name = "Pistol ammo"
		items.Rifle_Unlock:
			item_id = "rifle_unlock"
			item_name = "Rifle"
		items.Shotgun_Unlock:
			item_id = "shotgun_unlock"
			item_name = "Shotgun"
		items.Pistol_Unlock:
			item_id = "pistol_unlock"
			item_name = "Pistol"

func _on_interact():
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if item_id == "rifle_ammo" and player.get(item_id) + 1 > player.RIFLE_MAX_SIZE:
		item_picked_up.emit(0,item_name)
	elif item_id == "shotgun_shells" and player.get(item_id) + 1 > player.SHOTGUN_MAX_SIZE:
		item_picked_up.emit(0,item_name)
	elif item_id == "pistol_ammo" and player.get(item_id) + 1 > player.PISTOL_MAX_SIZE:
		item_picked_up.emit(0,item_name)
	else:
		player.set(item_id, player.get(item_id) + 1)
		item_picked_up.emit(1,item_name)
		queue_free()

