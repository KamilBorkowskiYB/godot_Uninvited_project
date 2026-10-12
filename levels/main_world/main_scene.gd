@tool
extends Node2D

var initialization_finished := false
@export_dir var main_level_scenes_folder: String = "":
	set(value):
		main_level_scenes_folder = value
		if not initialization_finished:
			return
		if Engine.is_editor_hint():
			find_main_scene_variants.call_deferred()

var main_scene_high: PackedScene


func _ready():
	if Engine.is_editor_hint():
		initialization_finished = true
		return


func find_main_scene_variants():
	main_scene_high = null
	if main_level_scenes_folder.is_empty():
		return
	if not DirAccess.dir_exists_absolute(main_level_scenes_folder):
		push_warning("Folder nie istnieje: " + main_level_scenes_folder)
		return
	var dir = DirAccess.open(main_level_scenes_folder)
	if dir == null:
		push_warning("Nie można otworzyć folderu: " + main_level_scenes_folder)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".tscn"):
				var scene_path = main_level_scenes_folder.path_join(file_name)
				if file_name.ends_with("_high.tscn"):
					main_scene_high = load(scene_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	notify_property_list_changed()
	
	#replacing scene tree
	replace_level_in_scene(self, main_scene_high)


func replace_level_in_scene(viewport, new_level_scene):
	if new_level_scene == null or viewport == null:
		return
	var old_level
	var new_level
	old_level = viewport.get_child(0)
	if old_level.name.contains("high"):
		viewport.remove_child(old_level)
		old_level.queue_free()
	new_level = new_level_scene.instantiate()
	viewport.add_child(new_level)
	viewport.move_child(new_level, 0)
	new_level.owner = get_tree().edited_scene_root
