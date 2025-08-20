extends Area2D

signal reveal_area
enum TriggerAction { REVEAL_PARENT, PASS_ON }

@export var action: TriggerAction = TriggerAction.REVEAL_PARENT

func _on_body_entered(body):
	if body.is_in_group("player"):
		trigger_event()


func trigger_event():
	match action:
		TriggerAction.REVEAL_PARENT:
			reveal_parent()
		TriggerAction.PASS_ON:
			pass_on_trigger()
	queue_free()


func reveal_parent():
	var parent_name = get_parent().name
	reveal_area.emit(parent_name)


func pass_on_trigger():
	pass


func play_cutscene():
	pass


func spawn_enemies():
	pass
