@tool
extends Node2D

@export var main_scene_level: PackedScene:
	set(value):
		main_scene_level = value
		if Engine.is_editor_hint() and main_scene_level:
			replace_level_in_scene()


#func replace_level_in_scene():
	##pass
	#var icon = load("res://icon.svg")
	#var sprite := Sprite2D.new()
	#sprite.name = "TestIcon"
	#sprite.texture = icon
	#self.add_child(sprite)
	#sprite.owner = get_tree().edited_scene_root


func replace_level_in_scene():
	pass
	## 1. Pobieramy ścieżkę do oryginalnego pliku .tscn
	#var scene_path = main_scene_level.resource_path
	#if scene_path.is_empty():
		#print("Ten PackedScene nie jest jeszcze zapisany w pliku!")
		#return
	## 2. Tworzymy instancję sceny w pamięci (poza głównym drzewem edytora)
	#var root_node = main_scene_level.instantiate()
	## 3. Modyfikujemy strukturę (dodajemy ikonę)
	#var icon = load("res://icon.svg")
	#var sprite := Sprite2D.new()
	#sprite.name = "TestIcon"
	#sprite.texture = icon
	#root_node.add_child(sprite)
	#
	## Ważne: owner dla nowego elementu musi wskazywać na korzeń tej ładowanej sceny
	#sprite.owner = root_node 
	## 4. Pakujemy zmodyfikowany węzeł z powrotem do PackedScene
	#var packed_scene = PackedScene.new()
	#var error = packed_scene.pack(root_node)
	#
	#if error == OK:
		## 5. Zapisujemy plik na dysku (nadpisujemy oryginał)
		#ResourceSaver.save(packed_scene, scene_path)
		#print("Zapisano zmiany do pliku źródłowego: ", scene_path)
		#
		## Opcjonalnie: odświeżamy zasób, aby edytor zauważył zmianę
		#main_scene_level = load(scene_path)
	#else:
		#print("Błąd podczas pakowania sceny!")
	## 6. Sprzątamy obiekt z pamięci operacyjnej
	#root_node.queue_free()
