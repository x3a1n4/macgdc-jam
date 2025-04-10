extends Area3D

@export_category("Dialogue")
@export var dialogue_resource : DialogueResource
@export var starting_point : String = "start"
@export var oneshot = false

var triggered = false

func _on_body_entered(body) -> void:
	if body is CharacterBody3D:
		if not triggered or not oneshot:
			DialogueManager.show_example_dialogue_balloon(dialogue_resource, starting_point)
			
			triggered = true
			return
